require 'spree_core'
require 'builder'
require 'xero_gateway'
require 'spree_xero_hooks'

module SpreeXero
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/util)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end

  class Payment < XeroGateway::Payment
    attr_accessor :date, :amount, :code, :invoice_number, :payment_id

    def to_xml(b = Builder::XmlMarkup.new)
      b.Payments {
          b.Payment {
          b.PaymentID self.payment_id if self.payment_id
          b.Date Payment.format_date(self.date || Date.today)
          b.Amount self.amount if self.amount
          b.Account { b.Code self.code } if self.code
          b.Invoice { b.invoice_number self.invoice_number } if self.invoice_number
        }
      }
    end

  end

end
