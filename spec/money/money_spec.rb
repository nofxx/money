# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Money do

  it {  Money.new(10_00).to_f.should eql(10.0) }
  it {  Money.new(10_00).to_s.should eql("10.00") }

  it "is associated to the singleton instance of VariableExchangeBank by default" do
    Money.new(0).bank.object_id.should == Money::VariableExchangeBank.instance.object_id
  end

  it "should return the amount of cents passed to the constructor" do
    Money.new(200_00, "USD").cents.should == 200_00
  end

  it "should rounds the given cents to an integer" do
    Money.new(1.0, "USD").cents.should == 1
    Money.new(1.01, "USD").cents.should == 1
  end

  it "should use the floor method" do
    Money.new(1.50, "USD").cents.should == 1
    Money.new(1.99, "USD").cents.should == 1
  end

  it "#currency returns the currency passed to the constructor" do
    Money.new(200_00, "USD").currency.should == "USD"
  end

  it "#zero? returns whether the amount is 0" do
    Money.new(0, "USD").should be_zero
    Money.new(0, "EUR").should be_zero
    Money.new(1, "USD").should_not be_zero
    Money.new(10, "YEN").should_not be_zero
    Money.new(-1, "EUR").should_not be_zero
  end

  it "should exchange_to exchanges the amount via its exchange bank" do
    money = Money.new(100_00, "USD")
    money.bank.should_receive(:exchange).with(100_00, "USD", "EUR").and_return(200_00)
    money.exchange_to("EUR")
  end

  it "#exchange_to exchanges the amount properly" do
    money = Money.new(100_00, "USD")
    money.bank.should_receive(:exchange).with(100_00, "USD", "EUR").and_return(200_00)
    money.exchange_to("EUR").should == Money.new(200_00, "EUR")
  end

  it "#== returns true if and only if their amount and currency are equal" do
    Money.new(1_00, "USD").should == Money.new(1_00, "USD")
  end

  it "#* multiplies the money's amount by the multiplier while retaining the currency" do
    (Money.new(1_00, "USD") * 10).should == Money.new(10_00, "USD")
  end

  it "#* divides the money's amount by the divisor while retaining the currency" do
    (Money.new(10_00, "USD") / 10).should == Money.new(1_00, "USD")
  end

  it "should create a new Money object of 0 cents if empty" do
    Money.empty.should == Money.new(0)
  end

  it "Money.ca_dollar creates a new Money object of the given value in CAD" do
    Money.ca_dollar(50).should == Money.new(50, "CAD")
  end

  it "Money.us_dollar creates a new Money object of the given value in USD" do
    Money.us_dollar(50).should == Money.new(50, "USD")
  end

  it "Money.euro creates a new Money object of the given value in EUR" do
    Money.euro(50).should == Money.new(50, "EUR")
  end

  it "Money.real creates a new Money object of the given value in BRL" do
    Money.real(50).should == Money.new(50, "BRL")
  end


  describe "Installments" do

    it "# divides the money ammout in installments add last" do
      @money = Money.new(10_00).split_in_installments(3)
      @money[0].cents.should eql(334)
      @money[1].cents.should eql(333)
      @money[2].cents.should eql(333)
    end

    it "# divides the money ammout in installments add first" do
      @money = Money.new(10_00).split_in_installments(3,true)
      @money.to_s.should eql(["3.34", "3.33", "3.33"])
    end

    it "# divides the money ammout in installments base on payment" do
      money = Money.new(3_00)
      Money.new(10_00).in_installments_of(money)[0].cents.should eql(334)
      Money.new(10_00).in_installments_of(money)[1].cents.should eql(333)
      Money.new(10_00).in_installments_of(money)[2].cents.should eql(333)
    end

    it "shuld sum array" do
      Money.new(10_00).split_in_installments(3).sum.cents.should eql(1000)
    end

    it "should calculate tax" do
      Money.new(100).add_tax(20).cents.should eql(120)
      Money.new(100).add_tax(-20).cents.should eql(80)
    end

    it "shuld sum array" do
      @money = Money.new(10_00).add_tax(10)
      @money.split_in_installments(3).sum.cents.should eql(1100)
    end

  end

  describe "Taxes and Interest" do

    it "Money.add_rate works" do
      Money.add_rate("EUR", "USD", 10)
      Money.new(10_00, "EUR").exchange_to("USD").should == Money.new(100_00, "USD")
    end

    it "Money method missing exchange" do
      Money.add_rate("EUR", "BRL", 10)
      Money.new(10_00, "EUR").as_brl.should == Money.new(100_00, "BRL")
    end

    it "should calculate compound tax" do
      m = Money.new(1000_00)
      m.compound_interest(12.99,12).to_s.should eql("137.91")
    end

    it "should simple interest" do
      m = Money.new(1000_00)
      m.simple_interest(12.99,12).to_s.should eql("129.90")
    end

    it "should calculate compound interest" do
      m = Money.new(2500_00)
      m.compound_interest(12.99,3).to_s.should eql("82.06")
    end

  end

  describe "Format out " do

    describe "Options" do
      before(:each) do
        @cash =  Money.new(2_00, "JPY")
      end

      it { @cash.format.should eql("¥2.00") }
      it { @cash.format(:symbol => "R$ ").should eql("R$ 2.00") }
      it { @cash.format(:no_cents => true).should eql("¥2") }
      it { @cash.format(:no_cents => true, :symbol => "R$ ").should eql("R$ 2") }
      it { @cash.format(:html => true).should eql("&yen;2.00") }

    end

    it { Money.new(0).format.should eql("$0.00") }
    it { Money.new(0).format(:display_free => true).should eql("free") }
    it { Money.new(0).format(:display_free => "GRATIS").should eql("GRATIS") }

    it { Money.new(9).format.should eql("$0.09") }
    it { Money.new(99).format.should eql("$0.99") }
    it { Money.new(800).format.should eql("$8.00") }
    it { Money.new(-8000).format(:no_cents => true).should eql("$-80") }
    it { Money.new(80000).format.should eql("$800.00") }
    it { Money.new(800000).format.should eql("$8,000.00") }
    it { Money.new(-8000000, "JPY").format(:no_cents => true).should eql("¥-80.000") }
    it { Money.new(87654321, "BRL").format.should eql("R$876.543,21") }
    it { Money.new(800000000, "BRL").format.should eql("R$8.000.000,00") }
    it { Money.new(8000000000, "BRL").format.should eql("R$80.000.000,00") }
    it { Money.new(80000000000, "CAD").format.should eql("$800,000,000.00") }
    it { Money.new(880000000000, "GBP").format(:no_cents => true).should eql("£8,800,000,000") }
    it { Money.new(8800000000088, "EUR").format.should eql("€88,000,000,000.88") }

  end


  describe "Actions involving two Money objects" do
    describe "if the other Money object has the same currency" do
      it "#<=> compares the two objects' amounts" do
        (Money.new(1_00, "USD") <=> Money.new(1_00, "USD")).should == 0
        (Money.new(1_00, "USD") <=> Money.new(99, "USD")).should > 0
        (Money.new(1_00, "USD") <=> Money.new(2_00, "USD")).should < 0
      end

      it "#+ adds the other object's amount to the current object's amount while retaining the currency" do
        (Money.new(10_00, "USD") + Money.new(90, "USD")).should == Money.new(10_90, "USD")
      end

      it "#- substracts the other object's amount from the current object's amount while retaining the currency" do
        (Money.new(10_00, "USD") - Money.new(90, "USD")).should == Money.new(9_10, "USD")
      end
    end

    describe "if the other Money object has a different currency" do
      it "#<=> compares the two objects' amount after converting the other object's amount to its own currency" do
        target = Money.new(200_00, "EUR")
        target.should_receive(:exchange_to).with("USD").and_return(Money.new(300_00, "USD"))
        (Money.new(100_00, "USD") <=> target).should < 0

        target = Money.new(200_00, "EUR")
        target.should_receive(:exchange_to).with("USD").and_return(Money.new(100_00, "USD"))
        (Money.new(100_00, "USD") <=> target).should == 0

        target = Money.new(200_00, "EUR")
        target.should_receive(:exchange_to).with("USD").and_return(Money.new(99_00, "USD"))
        (Money.new(100_00, "USD") <=> target).should > 0
      end

      it "#+ adds the other object's amount, converted to this object's currency, to this object's amount while retaining its currency" do
        other = Money.new(90, "EUR")
        other.should_receive(:exchange_to).with("USD").and_return(Money.new(9_00, "USD"))
        (Money.new(10_00, "USD") + other).should == Money.new(19_00, "USD")
      end

      it "#- substracts the other object's amount, converted to this object's currency, from this object's amount while retaining its currency" do
        other = Money.new(90, "EUR")
        other.should_receive(:exchange_to).with("USD").and_return(Money.new(9_00, "USD"))
        (Money.new(10_00, "USD") - other).should == Money.new(1_00, "USD")
      end
    end
  end
end
