require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Money::ExchangeBank do
  before :each do
    @bank = Money::ExchangeBank.new
  end

  it "returns the previously specified conversion rate" do
    @bank.add_rate("USD", "EUR", 0.788332676)
    @bank.add_rate("EUR", "YEN", 122.631477)
    @bank.get_rate("USD", "EUR").should == 0.788332676
    @bank.get_rate("EUR", "YEN").should == 122.631477
  end

   it "returns the previously specified conversion rate" do
    @bank.add_rate("USD", "EUR", 0.788332676)
    @bank.add_rate("EUR", "YEN", 122.631477)
    @bank.get_rate("USD", "EUR").should == 0.788332676
    @bank.get_rate("EUR", "YEN").should == 122.631477
  end

  it "treats currency names case-insensitively" do
    @bank.add_rate("usd", "eur", 1)
    @bank.get_rate("USD", "EUR").should == 1
    @bank.same_currency?("USD", "usd").should be_true
    @bank.same_currency?("EUR", "usd").should be_false
  end

  it "returns nil if the conversion rate is unknown" do
    @bank.get_rate("American Pesos", "EUR").should be_nil
  end

  it "exchanges money from one currency to another according to the specified conversion rates" do
    @bank.add_rate("USD", "EUR", 0.5)
    @bank.add_rate("EUR", "YEN", 10)
    @bank.exchange(10_00, "USD", "EUR").should == 5_00
    @bank.exchange(500_00, "EUR", "YEN").should == 5000_00
  end

  it "rounds the exchanged result down" do
    @bank.add_rate("USD", "EUR", 0.788332676)
    @bank.add_rate("EUR", "YEN", 122.631477)
    @bank.exchange(10_00, "USD", "EUR").should == 7_88
    @bank.exchange(500_00, "EUR", "YEN").should == 6131573
  end

  it "returns the previously specified conversion rate" do
    @bank.add_rate("EUR", 122.631477)
    @bank.get_rate("EUR").should == 122.631477
  end

  it "treats currency names case-insensitively" do
    @bank.add_rate("yen", 1)
    @bank.get_rate("YEN").should == 1
    @bank.same_currency?("USD", "usd").should be_true
    @bank.same_currency?("EUR", "usd").should be_false
  end

  it "should work with a different default currency" do
    Money.default_currency = "BRL"
    @bank.add_rate("yen", 10)
    @bank.exchange(5_00, "brl", "yen").should == 50_00
    Money.default_currency = "USD"
  end

  it "returns nil if the conversion rate is unknown" do
    @bank.get_rate("American Pesos").should be_nil
  end

  it "exchanges money from one currency to another according to the specified conversion rates" do
    @bank.add_rate("EUR", 0.5)
    @bank.add_rate("YEN", 5)
    @bank.exchange(10_00, "USD", "EUR").should == 5_00
    @bank.exchange(500_00, "USD", "YEN").should == 2500_00
    @bank.exchange(2500_00, "YEN", "USD").should == 500_00
  end

  it "should deal fine with FOO_TO_FOO" do
    @bank.add_rate("USD", 2.0)
    @bank.get_rate("USD").should be_nil
  end

  it "should test some more" do
    @bank.add_rate("EUR", 0.788332676)
    @bank.add_rate("YEN", 122.631477)
    @bank.exchange(10_00, "USD", "EUR").should == 788
    @bank.exchange(500_00, "USD", "YEN").should == 6131573
  end

  it "raises Money::UnknownRate upon conversion if the conversion rate is unknown" do
    block = lambda { @bank.exchange(10, "USD", "ABC") }
    block.should raise_error(Money::UnknownRate)
  end

  describe "Fetching Data" do

    before(:each) do
      URI.should_receive(:parse).with("http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml").and_return(:uri)
      Net::HTTP.should_receive(:get).with(:uri).and_return("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<gesmes:Envelope xmlns:gesmes=\"http://www.gesmes.org/xml/2002-08-01\" xmlns=\"http://www.ecb.int/vocabulary/2002-08-01/eurofxref\">\n\t<gesmes:subject>Reference rates</gesmes:subject>\n\t<gesmes:Sender>\n\t\t<gesmes:name>European Central Bank</gesmes:name>\n\t</gesmes:Sender>\n\t<Cube>\n\t\t<Cube time='2009-05-29'>\n\t\t\t<Cube currency='USD' rate='1.4098'/>\n\t\t\t<Cube currency='JPY' rate='135.22'/>\n\t\t\t<Cube currency='BGN' rate='1.9558'/>\n\t\t\t<Cube currency='CZK' rate='26.825'/>\n\t\t\t<Cube currency='DKK' rate='7.4453'/>\n\t\t\t<Cube currency='EEK' rate='15.6466'/>\n\t\t\t<Cube currency='GBP' rate='0.87290'/>\n\t\t\t<Cube currency='HUF' rate='282.48'/>\n\t\t\t<Cube currency='LTL' rate='3.4528'/>\n\t\t\t<Cube currency='LVL' rate='0.7093'/>\n\t\t\t<Cube currency='PLN' rate='4.4762'/>\n\t\t\t<Cube currency='RON' rate='4.1825'/>\n\t\t\t<Cube currency='SEK' rate='10.6678'/>\n\t\t\t<Cube currency='CHF' rate='1.5128'/>\n\t\t\t<Cube currency='NOK' rate='8.8785'/>\n\t\t\t<Cube currency='HRK' rate='7.3500'/>\n\t\t\t<Cube currency='RUB' rate='43.4455'/>\n\t\t\t<Cube currency='TRY' rate='2.1737'/>\n\t\t\t<Cube currency='AUD' rate='1.7671'/>\n\t\t\t<Cube currency='BRL' rate='2.8320'/>\n\t\t\t<Cube currency='CAD' rate='1.5501'/>\n\t\t\t<Cube currency='CNY' rate='9.6263'/>\n\t\t\t<Cube currency='HKD' rate='10.9273'/>\n\t\t\t<Cube currency='IDR' rate='14539.26'/>\n\t\t\t<Cube currency='INR' rate='66.4260'/>\n\t\t\t<Cube currency='KRW' rate='1764.04'/>\n\t\t\t<Cube currency='MXN' rate='18.4340'/>\n\t\t\t<Cube currency='MYR' rate='4.9167'/>\n\t\t\t<Cube currency='NZD' rate='2.2135'/>\n\t\t\t<Cube currency='PHP' rate='66.516'/>\n\t\t\t<Cube currency='SGD' rate='2.0350'/>\n\t\t\t<Cube currency='THB' rate='48.377'/>\n\t\t\t<Cube currency='ZAR' rate='11.2413'/>\n\t\t</Cube>\n\t</Cube>\n</gesmes:Envelope>")
    end

    it "should fetch data" do
      Money.default_currency = "EUR"
      @bank.fetch_rates
      @bank.get_rate("DKK").should be_close(7.4453, 0.0001)
      @bank.get_rate("BRL").should be_close(2.832, 0.001)
      @bank.exchange(10_00, "EUR", "DKK").should == 74_45
    end

    it "should fetch diff than eur" do
      Money.default_currency = "BRL"
      @bank.fetch_rates
      @bank.get_rate("DKK").should be_close(2.6289, 0.0001)
      @bank.get_rate("EEK").should be_close(5.5249, 0.0001)
      @bank.get_rate("EUR").should be_close(2.832, 0.001)
    end

    it "should fetch for an unknown one" do
      Money.default_currency = "XXX"
      @bank.fetch_rates
      @bank.get_rate("DKK").should be_nil
      @bank.get_rate("EUR", "USD").should be_close(1.4098, 0.001)
      Money.default_currency = "USD"

    end
  end

  describe "Live Fetching" do

    if ENV["LIVE"]

      it "should fetch data live" do
        @bank.fetch_rates
        @bank.get_rate("DKK").should_not be_nil
        @bank.get_rate("EUR").should_not be_nil
      end

    end

  end

end
