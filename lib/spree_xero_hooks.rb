class SpreeXeroHooks < Spree::ThemeSupport::HookListener
  Deface::Override.new(:virtual_path => "admin/configurations/index",
                       :insert_after => "[data-hook='admin_configurations_menu'], #admin_configurations_menu[data-hook]",
                       :text => "
        <tr>
          <td><%= link_to t('xero_settings'), admin_xero_settings_path %></td>
          <td><%= t(\"xero_settings\") %></td>
        </tr>
      ",
                       :disabled => false)
end