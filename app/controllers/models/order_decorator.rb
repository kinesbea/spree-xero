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
          contact = self.bill_address.submit_contact_to_xero
          if contact
            invoice.contact = contact
            invoice.contact.phone.number = self.bill_address.phone
          end
          self.line_items.each do |l|
            invoice.line_items << XeroGateway::LineItem.new(
                :description => l.product.name,
                :quantity => l.quantity,
                :unit_amount => l.price,
                :line_item_id => l.product.id,
                :account_code => '400',
                :tax_amount => 0.0
            )
          end
          result = gateway.create_invoice(invoice)
          saved_invoice = result.invoice if result.success?
        rescue XeroGateway::ApiException
        end
      end
    end
    saved_invoice
  end

end