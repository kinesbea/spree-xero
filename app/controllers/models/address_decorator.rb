Address.class_eval do
  def submit_contact_to_xero
    saved_contact = nil
    if XeroUtil.setup_exists?
      gateway = XeroUtil.gateway
      if (XeroUtil.error.nil?)
        begin
          address = {  :line_1 => self.address1, :city => self.city, :post_code => self.zipcode,
                       :region => self.state.name, :country => self.country.iso3 }
          address[:line_2] = self.address2 if !self.address2.empty?          
          contact = XeroGateway::Contact.new(:name => self.firstname+' '+self.lastname)
          contact.phone.number = self.phone
          contact.is_customer = true
          contact.add_address(address)
          result = gateway.create_contact(contact)
          saved_contact = result.contact if result.success?
        rescue XeroGateway::ApiException
          debugger
        end
      end
    end
    saved_contact
  end

end