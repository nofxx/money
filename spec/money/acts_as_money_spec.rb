require File.dirname(__FILE__) + '/../spec_helper.rb'
require File.dirname(__FILE__) + '/../../rails/init.rb'
require 'activerecord'

#load_schema
class Account < ActiveRecord::Base
  has_money :value, :total
end



describe "Acts as Money" do

  before(:each) do
    @account = Account.new(:value => 10, :total => 10)
  end

  it "should" do
    @account.value.should be_instance_of(Money)
  end

  it "should include nicely" do
    @account.value.to_s.should eql("10.00")
    @account.total.to_s.should eql("10.00")
  end

  it "should set currency" do
    @account.value_currency.should eql("USD")
  end


end