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

end

module XeroGateway
  class Payment
    include Money
    include Dates

    # Any errors that occurred when the #valid? method called.
    attr_reader :errors

    # All accessible fields
    attr_accessor :date, :amount, :code, :invoice_number, :payment_id
        
    def initialize(params = {})
      @errors ||= []

      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def to_xml(b = Builder::XmlMarkup.new)
        b.Payment {
        b.PaymentID self.payment_id if self.payment_id
        b.Date Payment.format_date(self.date || Date.today)
        b.Amount self.amount if self.amount
        b.Account { b.Code self.code } if self.code
        b.Invoice { b.InvoiceNumber self.invoice_number } if self.invoice_number
      }
    end

    def self.from_xml(payment_element)
      payment = Payment.new
      payment_element.children.each do | element |
        case element.name
          when 'Date' then    payment.date = parse_date_time(element.text)
          when 'Amount' then  payment.amount = BigDecimal.new(element.text)
          when 'PaymentID' then  payment.payment_id = element.text
        end
      end
      payment
    end

    def ==(other)
      [:date, :amount].each do |field|
        return false if send(field) != other.send(field)
      end
      return true
    end

  end
end
