# -*- coding: utf-8 -*-
require 'money/variable_exchange_bank'

# Represents an amount of money in a certain currency.
class Money
  include Comparable

  attr_reader :cents, :currency, :bank

  class << self
    # Each Money object is associated to a bank object, which is responsible
    # for currency exchange. This property allows one to specify the default
    # bank object.
    #
    #   bank1 = MyBank.new
    #   bank2 = MyOtherBank.new
    #e if VariableExchangeBank.
    # It allows one to specify custom exchange rates:
    #
    #   Money.default_bank.add_rate("USD", "CAD", 1.24515)
    #   Money.default_bank.add_rate("CAD", "USD", 0.803115)
    #   Money.us_dollar(100).exchange_to("CAD")  # => MONEY.ca_dollar(124)
    #   Money.ca_dollar(100).exchange_to("USD")  # => Money.us_dollar(80)
    attr_accessor :default_bank

    # the default currency, which is used when <tt>Money.new</tt> is called
    # without an explicit currency argument. The default value is "USD".
    attr_accessor :default_currency
  end

  CURRENCIES = {
    "USD" => { :delimiter => ",", :separator => ".", :symbol => "$" },
    "CAD" => { :delimiter => ",", :separator => ".", :symbol => "$" },
    "HKD" => { :delimiter => ",", :separator => ".", :symbol => "$" },
    "SGD" => { :delimiter => ",", :separator => ".", :symbol => "$" },
    "BRL" => { :delimiter => ".", :separator => ",", :symbol => "R$" },
    "EUR" => { :delimiter => ",", :separator => ".", :symbol => '€', :html => '&euro;' },
    "GBP" => { :delimiter => ",", :separator => ".", :symbol => '£', :html => '&pound;' },
    "JPY" => { :delimiter => ".", :separator => ".", :symbol => '¥', :html => '&yen;' },
  }
  self.default_bank = VariableExchangeBank.instance
  self.default_currency = "USD"


  # Create a new money object with value 0.
  def self.empty(currency = default_currency)
    Money.new(0, currency)
  end

  # Creates a new Money object of the given value, using the Canadian dollar currency.
  def self.ca_dollar(cents)
    Money.new(cents, "CAD")
  end

  # Creates a new Money object of the given value, using the American dollar currency.
  def self.us_dollar(cents)
    Money.new(cents, "USD")
  end

  # Creates a new Money object of the given value, using the Euro currency.
  def self.euro(cents)
    Money.new(cents, "EUR")
  end

  # Creates a new Money object of the given value, using the Brazilian Real currency.
  def self.real(cents)
    Money.new(cents, "BRL")
  end

  def self.add_rate(from_currency, to_currency, rate)
    Money.default_bank.add_rate(from_currency, to_currency, rate)
  end

  # Creates a new money object.
  #  Money.new(100)
  #
  # Alternativly you can use the convinience methods like
  # Money.ca_dollar and Money.us_dollar
  def initialize(cents, currency = Money.default_currency, bank = Money.default_bank)
    @cents = cents.to_i
    @currency = currency || default_currency
    @bank = bank
  end

  # Do two money objects equal? Only works if both objects are of the same currency
  def ==(other_money)
    cents == other_money.cents && bank.same_currency?(currency, other_money.currency)
  end

  def <=>(other_money)
    if bank.same_currency?(currency, other_money.currency)
      cents <=> other_money.cents
    else
      cents <=> other_money.exchange_to(currency).cents
    end
  end

  def +(other_money)
    if currency == other_money.currency
      Money.new(cents + other_money.cents, other_money.currency)
    else
      Money.new(cents + other_money.exchange_to(currency).cents,currency)
    end
  end

  def -(other_money)
    if currency == other_money.currency
      Money.new(cents - other_money.cents, other_money.currency)
    else
      Money.new(cents - other_money.exchange_to(currency).cents, currency)
    end
  end

  # get the cents value of the object
  def cents
    @cents
  end

  # multiply money by fixnum
  def *(fixnum)
    Money.new(cents * fixnum, currency)
  end

  # divide money by fixnum
  # check out split_in_installments method too
  def /(fixnum)
    Money.new(cents / fixnum, currency)
  end

  def %(fixnum)
    Money.new(cents % fixnum, currency)
  end

  # Test if the money amount is zero
  def zero?
    cents == 0
  end

  # Calculates compound interest
  # Returns a money object with the sum of self + it
  def compound_interest(rate,count=1)
    Money.new(cents * ((1 + rate / 100.0 / 12) ** count - 1))
  end

  # Calculate self + simple interest
  def simple_interest(rate,count=1)
    Money.new(rate/100/12*cents*count)
  end

  # Split money in number of installments
  #
  # Money.new(10_00).split_in_installments(3)
  # => [ 3.34, 3.33, 3.33 ]  (All Money instances)
  #
  def split_in_installments(fixnum,extra=nil,*opts)
    wallet = Wallet.new(fixnum, Money.new(cents/fixnum,currency))
    to_add = cents % fixnum
    to_add.times { |m| wallet[m] += Money.new(1) }
    wallet
  end

  # Split money in installments based on payment value
  #
  # Money.new(1000_00).split_in_installments(Money.new(300_00))
  # => [ 334_00, 333_00, 333_00 ]  (All Money instances)
  #
  def in_installments_of(other_money,first=false)
    split_in_installments(cents/other_money.cents,first)
  end

  # Just a helper if you got tax inputs in percentage.
  # Ie. add_tax(20) =>  cents * 1.20
  def add_tax(tax)
    Money.new(cents + cents / 100 * tax)
  end

  # Format the price according to several rules
  # Currently supported are :with_currency, :no_cents, :symbol and :html
  #
  # with_currency:
  #
  #  Money.ca_dollar(0).format => "free"
  #  Money.ca_dollar(100).format => "$1.00"
  #  Money.ca_dollar(100).format(:with_currency => true) => "$1.00 CAD"
  #  Money.us_dollar(85).format(:with_currency => true) => "$0.85 USD"
  #
  # no_cents:
  #
  #  Money.ca_dollar(100).format(:no_cents) => "$1"
  #  Money.ca_dollar(599).format(:no_cents) => "$5"
  #
  #  Money.ca_dollar(570).format(:no_cents, :with_currency) => "$5 CAD"
  #  Money.ca_dollar(39000).format(:no_cents) => "$390"
  #
  # symbol:
  #
  #  Money.new(100, :currency => "GBP").format(:symbol => "£") => "£1.00"
  #
  # html:
  #
  #  Money.ca_dollar(570).format(:html => true, :with_currency => true) =>  "$5.70 <span class=\"currency\">CAD</span>"
   def format(*rules)
    # support for old format parameters
    rules = normalize_formatting_rules(rules)

    if cents == 0
      if rules[:display_free].respond_to?(:to_str)
        return rules[:display_free]
      elsif rules[:display_free]
        return "free"
      end
    end

    if rules.has_key?(:symbol)
      if rules[:symbol]
        symbol = rules[:symbol]
      else
        symbol = ""
      end
    else
      symbol = CURRENCIES[currency][:symbol]
    end
    self.currency

    if rules[:no_cents]
      formatted = sprintf("#{symbol}%d", cents.to_f / 100)
      formatted.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{CURRENCIES[currency][:delimiter]}")
    else
      formatted = sprintf("#{symbol}%.2f", cents.to_f / 100).split('.')
      formatted[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{CURRENCIES[currency][:delimiter]}")
      formatted = formatted.join(CURRENCIES[currency][:separator])
    end

    # Commify ("10000" => "10,000")
    formatted.gsub!(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')

    if rules[:with_currency]
      formatted << " "
      formatted << '<span class="currency">' if rules[:html]
      formatted << currency
      formatted << '</span>' if rules[:html]
    end
    formatted.gsub!(CURRENCIES[currency][:symbol],CURRENCIES[currency][:html]) if rules[:html]
    formatted
   end

   def normalize_formatting_rules(rules)
    if rules.size == 1
      rules = rules.pop
      rules = { rules => true } if rules.is_a?(Symbol)
    else
      rules = rules.inject({}) do |h,s|
        h[s] = true
        h
      end
    end
    rules
  end


  # Money.ca_dollar(100).to_s => "1.00"
  def to_s
    sprintf("%.2f", cents / 100.0)
  end

  # Money.ca_dollar(100).to_f => "1.0"
  def to_f
    cents / 100.0
  end

  # Recieve the amount of this money object in another currency.
  def exchange_to(other_currency)
    Money.new(@bank.exchange(self.cents, currency, other_currency), other_currency)
  end

  # Conversation to self
  def to_money
    self
  end

  def method_missing(m,*x)
    if m.to_s =~ /^as/
      exchange_to(m.to_s.split("_").last.upcase)
    else
      super
    end
  end
end

#
# Represent a financial array.
# Investment/Time/Installments...
#
class Wallet < Array

  def to_s
    map &:to_s
  end

  def sum
    Money.new(inject(0){ |sum,m| sum + m.cents })
  end

end
