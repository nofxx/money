require 'money/errors'
require 'net/http'
require 'rubygems'
begin
  require "nokogiri"
  Parser = Nokogiri
rescue
  require "hpricot"
  Parser = Hpricot
end
# Class for aiding in exchanging money between different currencies.
# By default, the Money class uses an object of this class (accessible through
# Money#bank) for performing currency exchanges.
#
# By default, ExchangeBank has no knowledge about conversion rates.
# One must manually specify them with +add_rate+, after which one can perform
# exchanges with +exchange+. For example:
#
#  bank = Money::ExchangeBank.new
#  bank.add_rate("CAD", 0.803115)
#  bank.add_rate("USD", 1.24515)
#
#  # Exchange 100 CAD to USD:
#  bank.exchange(100_00, "CAD", "USD")  # => 15504
#  # Exchange 100 USD to CAD:
#  bank.exchange(100_00, "USD", "CAD")  # => 6450
class Money
  class ExchangeBank
    #
    # Rates to be autofetched
    attr_accessor :default_rates

    # Returns the singleton instance of ExchangeBank.
    #
    # By default, <tt>Money.default_bank</tt> returns the same object.
    def self.instance
      @@singleton
    end

    def initialize
      @rates = {}
      @mutex = Mutex.new
    end

    def add_rate(*params)
      if rate = params.delete_at(2)
        parse_rate(rate, *params)
      else
        parse_rate(params[1], Money.default_currency, params[0])
      end
    end

    def parse_rate(rate,from,to)
      return if from.upcase == to.upcase
      @mutex.synchronize do
        @rates["#{from}<>#{to}".upcase] = rate
        @rates["#{to}<>#{from}".upcase] = 1.0/rate
        @rates["sync_at"] = Time.now.to_i
      end
    end

    def get_rate(from, to = nil)
      from, to = Money.default_currency, from unless to
      @mutex.synchronize do
        @rates["#{from}<>#{to}".upcase]
      end
    end

    # Given two currency names, checks whether they're both the same currency.
    #
    #   bank = ExchangeBank.new
    #   bank.same_currency?("usd", "USD")   # => true
    #   bank.same_currency?("usd", "EUR")   # => false
    def same_currency?(currency1, currency2)
      currency1.upcase == currency2.upcase
    end

    # Exchange the given amount of cents in +from_currency+ to +to_currency+.
    # Returns the amount of cents in +to_currency+ as an integer, rounded down.
    #
    # If the conversion rate is unknown, then Money::UnknownRate will be raised.
    def exchange(cents, from, to)
      rate =  get_rate(from, to)
      raise(Money::UnknownRate, "No conversion rate for #{from} -> #{to}") unless rate
      (cents * rate).floor
    end

    def fetch_rate(from, to)

    end

    # Fetch rates
    def fetch_rates
      xml = Parser::XML(Net::HTTP.get(URI.parse('http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml')))
      curr = (xml/:Cube).select { |r| r["currency"] == Money.default_currency }.first
      diff = Money.default_currency == "EUR" || !curr ? 1 : curr["rate"].to_f
      (xml/:Cube).each do |x|
        r = x['rate'].to_f
        c = x['currency'] || ""
        unless default_rates && !default_rates.include?(c)
          parse_rate r / diff, curr ? Money.default_currency : "EUR", c.upcase
        end
      end
      parse_rate diff, Money.default_currency, "EUR" if curr
      self
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

    @@singleton = ExchangeBank.new
  end
end
