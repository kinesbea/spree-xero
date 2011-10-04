class AddXeroAcctCodeToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :xero_acct_code, :string
  end

  def self.down
    remove_column :products, :xero_acct_code
  end
end
