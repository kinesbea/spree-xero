class Admin::XeroSettingsController < Admin::BaseController

  def update

    if params[:preferences][:sale_dflt_acct_code].empty? || params[:preferences][:shipping_acct_code].empty? || params[:preferences][:adjustment_acct_code].empty? || params[:preferences][:payment_acct_code].empty?
      flash[:error] = I18n.t("xero_gl_code_required")
      redirect_to edit_admin_xero_settings_path
    else
      Spree::Config.set(params[:preferences])
      debugger
      name =  params[:private_key_file].original_filename
      directory = "#{RAILS_ROOT}/config"
      path = File.join(directory, name)
      File.open(path, "wb") { |f| f.write(params[:private_key_file].read) }
      Spree::Config.set({ :private_key_file => name })

      redirect_to admin_xero_settings_path
    end
  end
  def test
    gateway = XeroUtil.gateway
    if (XeroUtil.error.nil?)
      @result = gateway.get_contacts.contacts
    end
  end
end