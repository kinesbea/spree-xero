Payment.class_eval do
  def submit_payment_to_xero
#    saved_payment = nil
    if XeroUtil.setup_exists?
#        begin
          payment = SpreeXero::Payment.new({:invoice_number => order.id,:amount => amount,:code => '102'})
          debugger
          result = XeroUtil.create_payment(payment)
          saved_payment = result.payment if result.success?
#        rescue XeroGateway::ApiException
#        end
    end
#    saved_payment
  end

end