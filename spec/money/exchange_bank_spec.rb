require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Money::VariableExchangeBank do
  before :each do
    @bank = Money::VariableExchangeBank.new
  end

  it "returns the previously specified conversion rate" do
    @bank.add_rate("USD", 0.788332676)
    @bank.add_rate("EUR", 122.631477)
    @bank.get_rate("USD").should == 0.788332676
    @bank.get_rate("EUR").should == 122.631477
  end

  it "treats currency names case-insensitively" do
    @bank.add_rate("usd", 1)
    @bank.get_rate("USD").should == 1
    @bank.same_currency?("USD", "usd").should be_true
    @bank.same_currency?("EUR", "usd").should be_false
  end

  it "returns nil if the conversion rate is unknown" do
    @bank.get_rate("American Pesos").should be_nil
  end

  it "exchanges money from one currency to another according to the specified conversion rates" do
    @bank.add_rate("USD", 1.0)
    @bank.add_rate("EUR", 0.5)
    @bank.add_rate("YEN", 5)
    @bank.exchange(10_00, "USD", "EUR").should == 5_00
    @bank.exchange(500_00, "EUR", "YEN").should == 5000_00
  end

  it "rounds the exchanged result down" do
    @bank.add_rate("USD", 1.0)
    @bank.add_rate("EUR", 0.788332676)
    @bank.add_rate("YEN", 122.631477)
    @bank.exchange(10_00, "USD", "EUR").should == 788
    @bank.exchange(500_00, "EUR", "YEN").should == 7777901
  end

  it "raises Money::UnknownRate upon conversion if the conversion rate is unknown" do
    block = lambda { @bank.exchange(10, "USD", "ABC") }
    block.should raise_error(Money::UnknownRate)
  end
end
