Payment.class_eval do
  def submit_payment_to_xero
    saved_payment = nil
    if XeroUtil.setup_exists?
        begin
          payment = XeroGateway::Payment.new({:invoice_number => order.id,:amount => amount ,:code => Spree::Config[:payment_acct_code]})
          result = XeroUtil.create_payment(payment)
          saved_payment = result.payment if result.success?
        rescue XeroGateway::ApiException => exc
        end
    end
    saved_payment
  end

end