require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Money core extensions" do
  describe "Numberic#to_money works" do
    it "should convert integer to money" do
      money = 1234.to_money
      money.cents.should == 1234_00
      money.currency.should == Money.default_currency
    end

    it "should convert float to money" do
      money = 100.37.to_money
      money.cents.should == 100_37
      money.currency.should == Money.default_currency
    end
  end

  describe "String#to_money works" do
    it { "20.15".to_money.should == Money.new(20_15) }
    it { "100".to_money.should == Money.new(100_00) }
    it { "100.37".to_money.should == Money.new(100_37) }
    it { "100,37".to_money.should == Money.new(100_37) }
    it { "100 000".to_money.should == Money.new(100_000_00) }
    it { "100.000,45".to_money.should == Money.new(100_000_45) }
    it { "-100.100,45".to_money.should == Money.new(-100_100_45) }

    it { "100 USD".to_money.should == Money.new(100_00, "USD") }
    it { "-100 USD".to_money.should == Money.new(-100_00, "USD") }
    it { "100 EUR".to_money.should == Money.new(100_00, "EUR") }
    it { "100.37 EUR".to_money.should == Money.new(100_37, "EUR") }
    it { "100,37 EUR".to_money.should == Money.new(100_37, "EUR") }

    it { "USD 100".to_money.should == Money.new(100_00, "USD") }
    it { "EUR 100".to_money.should == Money.new(100_00, "EUR") }
    it { "EUR 100.37".to_money.should == Money.new(100_37, "EUR") }
    it { "CAD -100.37".to_money.should == Money.new(-100_37, "CAD") }
    it { "EUR 100,37".to_money.should == Money.new(100_37, "EUR") }
    it { "EUR -100,37".to_money.should == Money.new(-100_37, "EUR") }

    it { "BRL 100,37".to_money.should == Money.new(100_37, "BRL") }
    it { "BRL -100,37".to_money.should == Money.new(-100_37, "BRL") }

    it {"$100 USD".to_money.should == Money.new(100_00, "USD") }
  end
end
