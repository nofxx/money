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

  describe "String#to_money" do
    EXAMPLES = {
      "20.15" => {:cents => Money.new(20_15), :no_cents => Money.new(20_15)},
      "100" => {:cents => Money.new(100_00), :no_cents => Money.new(100)},
      "100.37" => {:cents => Money.new(100_37), :no_cents => Money.new(100_37)},
      "100,37" => {:cents => Money.new(100_37), :no_cents => Money.new(100_37)},
      "100 000" => {:cents => Money.new(100_000_00), :no_cents => Money.new(100_000)},
      "100.000,45" => {:cents => Money.new(100_000_45), :no_cents => Money.new(100_000_45)},
      "-100.100,45" => {:cents => Money.new(-100_100_45), :no_cents => Money.new(-100_100_45)},

      "100 USD" => {:cents => Money.new(100_00, "USD"), :no_cents => Money.new(100, "USD")},
      "-100 USD" => {:cents => Money.new(-100_00, "USD"), :no_cents => Money.new(-100, "USD")},
      "100 EUR" => {:cents => Money.new(100_00, "EUR"), :no_cents => Money.new(100, "EUR")},
      "100.37 EUR" => {:cents => Money.new(100_37, "EUR"), :no_cents => Money.new(100_37, "EUR")},
      "100,37 EUR" => {:cents => Money.new(100_37, "EUR"), :no_cents => Money.new(100_37, "EUR")},

      "USD 100" => {:cents => Money.new(100_00, "USD"), :no_cents => Money.new(100, "USD")},
      "EUR 100" => {:cents => Money.new(100_00, "EUR"), :no_cents => Money.new(100, "EUR")},
      "EUR 100.37" => {:cents => Money.new(100_37, "EUR"), :no_cents => Money.new(100_37, "EUR")},
      "CAD -100.37" => {:cents => Money.new(-100_37, "CAD"), :no_cents => Money.new(-100_37, "CAD")},
      "EUR 100,37" => {:cents => Money.new(100_37, "EUR"), :no_cents => Money.new(100_37, "EUR")},
      "EUR -100,37" => {:cents => Money.new(-100_37, "EUR"), :no_cents => Money.new(-100_37, "EUR")},

      "BRL 100,37" => {:cents => Money.new(100_37, "BRL"), :no_cents => Money.new(100_37, "BRL")},
      "BRL -100,37" => {:cents => Money.new(-100_37, "BRL"), :no_cents => Money.new(-100_37, "BRL")},

      "$100 USD" => {:cents => Money.new(100_00, "USD"), :no_cents => Money.new(100, "USD")}
    }

    EXAMPLES.each_pair do |string, expected_money|
      it "should convert '#{string}' with cents by default" do
        string.to_money.should == expected_money[:cents]
      end

      it "should convert '#{string}' without cents" do
        string.to_money(true).should == expected_money[:no_cents]
      end

      it "should convert '#{string}' with cents" do
        string.to_money(false).should == expected_money[:cents]
      end
    end
  end
end
