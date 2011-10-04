Order.class_eval do
  def submit_invoice_to_xero
    saved_invoice = nil
    if XeroUtil.setup_exists?
      gateway = XeroUtil.gateway
      if (XeroUtil.error.nil?)
        begin
          invoice = XeroGateway::Invoice.new({
            :invoice_type => "ACCREC",
            :due_date => 1.month.from_now,
            :invoice_number => self.id,
            :reference => self.number,
            :invoice_status => "AUTHORISED",
            :line_amount_types => "NoTax"
          })
          invoice.contact = get_contact_for_xero
          load_line_items_for_xero(invoice)
          load_adjustments_for_xero(invoice)
          
          result = gateway.create_invoice(invoice)
          saved_invoice = result.invoice if result.success?
        rescue XeroGateway::ApiException => exc
          debugger
        end
      end
    end
    saved_invoice
  end

  private
  def get_contact_for_xero
    address = {  :line_1 => self.bill_address.address1, :city => self.bill_address.city, :post_code => self.bill_address.zipcode,
                 :region => self.bill_address.state.name, :country => self.bill_address.country.iso3 }
    address[:line_2] = self.bill_address.address2 if !self.bill_address.address2.empty?
    contact = XeroGateway::Contact.new(:name => self.bill_address.firstname+' '+self.bill_address.lastname)
    contact.is_customer = true
    contact.phone.number = self.bill_address.phone
    contact.add_address(address)
    contact
  end

  def load_adjustments_for_xero(invoice)
    self.adjustments.each do |a|
      adj = XeroGateway::LineItem.new(:quantity => 1,:unit_amount => a.amount, :line_item_id => a.source_type,:tax_amount => 0.0)
      adj.description = a.label.empty? ? a.source_type : a.label
      adj.account_code = Spree::Config[:adjustment_acct_code]
      adj.account_code = Spree::Config[:shipping_acct_code] if "Shipment" == a.source_type
      invoice.line_items << adj
    end
  end

  def load_line_items_for_xero(invoice)
    self.line_items.each do |l|
      invoice.line_items << XeroGateway::LineItem.new(
          :description => l.product.name,
          :quantity => l.quantity,
          :unit_amount => l.price,
          :line_item_id => l.product.id,
          :account_code => l.product.xero_acct_code ? Spree::Config[:sale_dflt_acct_code]:l.product.xero_acct_code,
          :tax_type => 'NONE',
          :tax_amount => 0.0
      )
    end
  end

end