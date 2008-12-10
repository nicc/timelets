require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Customer, "when new" do
  before(:each) do
    @customer = Customer.new
  end

  it "should not be valid" do
    @customer.should_not be_valid
  end
  
  it "should require a name" do
    @customer.should have(1).error_on(:name)
  end
  
  it "should require a billing_cycle" do
    @customer.should have(1).error_on(:billing_cycle_id)
  end
end

describe Customer, "when updated" do
  before(:each) do
    @customer = Factory(:customer)
  end
  
  it "should allow updates" do
    @customer.name = "new name"
    @customer.save!
    @customer.should be_valid
    @customer.name.should eql("new name")
  end
  
  it "should not allow duplicate names" do
    Factory(:customer, :name => "duplicate name")
    @customer.name = "duplicate name"
    @customer.should_not be_valid
    @customer.should have(1).error_on(:name)
  end
end

describe Customer, "when loaded" do
  it "should have a name" do
    @customer = Factory(:customer, :name => "Mr Nice Guy")
    @customer.name.should eql("Mr Nice Guy")
  end
  
  it "should have a billing cycle" do
    @customer = Factory(:customer)
    @customer.billing_cycle.should be_an_instance_of(BillingCycle)
  end
  
  it "should have contracts" do
    @customer = Factory(:customer)
    Factory(:rate_contract, :customer => @customer)
    Factory(:rate_contract, :customer => @customer)
    @customer.should have(2).contracts
  end
end
