class Admin::XeroSettingsController < Admin::BaseController
  def update
    Spree::Config.set(params[:preferences])
    respond_to do |format|
      format.html {
        redirect_to admin_xero_settings_path
      }
    end
  end
  
  def test
    gateway = XeroUtil.gateway
    if (XeroUtil.error.nil?)
      @result = gateway.get_contacts.contacts
    end
  end
end