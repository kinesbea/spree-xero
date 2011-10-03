class XeroUtil
  include XeroGateway::Http

  def self.setup_exists?
    if Spree::Config[:xero_consumer_key].empty? || Spree::Config[:xero_consumer_secret].empty?
      false
    else
      true
    end
  end

  def self.gateway
    @error = nil
    if @gateway.nil?
      if self.setup_exists?
        @gateway = XeroGateway::PrivateApp.new(Spree::Config[:xero_consumer_key], Spree::Config[:xero_consumer_secret], "#{RAILS_ROOT}/config/privatekey.pem")
      else
        @error = I18n.t('xero_no_setup')
      end
    else
      @gateway
    end
  end

  def self.error
    @error ||= nil
  end

  def self.create_payment(payment)
    x = XeroUtil.new
    gateway_instance = self.gateway
    if (error.nil?)
      request_xml = payment.to_xml
      response_xml = x.http_put(gateway_instance.client, "#{gateway_instance.xero_url}/Payments", request_xml, {})
      
      response = x.parse_response(response_xml, {:request_xml => request_xml}, {:request_signature => 'PUT/payments'})
      response.response_item = response.payments.first
      if response.success? && response.payment && response.payment.payment_id
        payment.payment_id = response.payment.payment_id
      end
      response
    end
  end

  def logger
    false
  end

  def parse_response(raw_response, request = {}, options = {})

    response = XeroGateway::Response.new

    doc = REXML::Document.new(raw_response, :ignore_whitespace_nodes => :all)
    # check for responses we don't understand
    raise UnparseableResponse.new(doc.root.name) unless doc.root.name == "Response"

    response_element = REXML::XPath.first(doc, "/Response")
    response_element.children.reject { |e| e.is_a? REXML::Text }.each do |element|
      case(element.name)
        when "ID" then response.response_id = element.text
        when "Status" then response.status = element.text
        when "ProviderName" then response.provider = element.text
        when "DateTimeUTC" then response.date_time = element.text
        when "Contact" then response.response_item = Contact.from_xml(element, self)
        when "Invoice" then response.response_item = Invoice.from_xml(element, self, {:line_items_downloaded => options[:request_signature] != "GET/Invoices"})
        when "Payment" then response.response_item = Payment.from_xml(element, self)
        when "Contacts" then element.children.each {|child| response.response_item << Contact.from_xml(child, self) }
        when "Invoices" then element.children.each {|child| response.response_item << Invoice.from_xml(child, self, {:line_items_downloaded => options[:request_signature] != "GET/Invoices"}) }
        when "CreditNotes" then element.children.each {|child| response.response_item << CreditNote.from_xml(child, self, {:line_items_downloaded => options[:request_signature] != "GET/CreditNotes"}) }
        when "Accounts" then element.children.each {|child| response.response_item << Account.from_xml(child) }
        when "TaxRates" then element.children.each {|child| response.response_item << TaxRate.from_xml(child) }
        when "Currencies" then element.children.each {|child| response.response_item << Currency.from_xml(child) }
        when "Organisations" then response.response_item = Organisation.from_xml(element.children.first) # Xero only returns the Authorized Organisation
        when "TrackingCategories" then element.children.each {|child| response.response_item << TrackingCategory.from_xml(child) }
        when "Errors" then element.children.each { |error| parse_error(error, response) }
      end
    end if response_element

    # If a single result is returned don't put it in an array
    if response.response_item.is_a?(Array) && response.response_item.size == 1
      response.response_item = response.response_item.first
    end

    response.request_params = request[:request_params]
    response.request_xml    = request[:request_xml]
    response.response_xml   = raw_response
    response
  end

end