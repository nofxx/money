require 'money/errors'
require 'net/http'
require 'rubygems'
require 'hpricot'

# Class for aiding in exchanging money between different currencies.
# By default, the Money class uses an object of this class (accessible through
# Money#bank) for performing currency exchanges.
#
# By default, VariableExchangeBank has no knowledge about conversion rates.
# One must manually specify them with +add_rate+, after which one can perform
# exchanges with +exchange+. For example:
#
#  bank = Money::VariableExchangeBank.new
#  bank.add_rate("CAD", 0.803115)
#  bank.add_rate("USD", 1.24515)
#  
#  # Exchange 100 CAD to USD:
#  bank.exchange(100_00, "CAD", "USD")  # => 15504
#  # Exchange 100 USD to CAD:
#  bank.exchange(100_00, "USD", "CAD")  # => 6450
class Money
  class VariableExchangeBank
    # Returns the singleton instance of VariableExchangeBank.
    #
    # By default, <tt>Money.default_bank</tt> returns the same object.
    def self.instance
      @@singleton
    end
    
    def initialize
      @rates = {}
      @rates["USD"] = 1.0
      @mutex = Mutex.new
    end

    def add_rate(currency, rate)
      @mutex.synchronize do
        @rates[currency.upcase] = (currency.upcase != Money.default_currency) ? (rate * @rates[Money.default_currency]) : rate
      end
    end

    def get_rate(currency = nil)
      @mutex.synchronize do
        return nil unless @rates[currency]
        (currency != Money.default_currency) ? @rates[currency.upcase] / @rates[Money.default_currency] : @rates[currency.upcase]
      end
    end
    
    # Given two currency names, checks whether they're both the same currency.
    #
    #   bank = VariableExchangeBank.new
    #   bank.same_currency?("usd", "USD")   # => true
    #   bank.same_currency?("usd", "EUR")   # => false
    def same_currency?(currency1, currency2)
      currency1.upcase == currency2.upcase
    end
    
    # Exchange the given amount of cents in +from_currency+ to +to_currency+.
    # Returns the amount of cents in +to_currency+ as an integer, rounded down.
    #
    # If the conversion rate is unknown, then Money::UnknownRate will be raised.
    def exchange(cents, from_currency, to_currency)
      from_currency.upcase!
      to_currency.upcase!
      if !@rates[from_currency] or !@rates[to_currency]        
        raise Money::UnknownRate, "No conversion rate known for '#{from_currency}' -> '#{to_currency}'"
      end
      ((cents / @rates[from_currency]) * @rates[to_currency]).round
    end

    # Fetch rates
    def fetch_rates
      xml = Hpricot.XML(
        Net::HTTP.get(
          URI.parse('http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml')
                     )
             )

      @rates["EUR"] = 1.0
      (xml/:Cube).each do |ele|
        @rates[ele['currency'].upcase] = ele['rate'].to_f if ele['currency']
      end
    end


    # Auto fetch the currencies every X seconds
    # if no time is give, will fetch every hour
    def auto_fetch(time = 60*60)
      @auto_fetch.kill if (@auto_fetch && @auto_fetch.alive?)
      @auto_fetch = Thread.new {
        loop do
          self.fetch_rates
          sleep time
        end
      }
    end

    # stop auto fetch
    def stop_fetch
      @auto_fetch.kill if (@auto_fetch && @auto_fetch.alive?)
    end
    
    @@singleton = VariableExchangeBank.new
  end
end
