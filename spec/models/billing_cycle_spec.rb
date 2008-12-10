require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BillingCycle, "when new" do
  before(:each) do
    @billing_cycle = BillingCycle.new
  end

  it "should be invalid" do
    @billing_cycle.should_not be_valid
  end
  
  it "should require a name" do
    @billing_cycle.should have(1).error_on(:name)
  end
  
  it "should require a day_of_month value" do
    @billing_cycle.should have(2).error_on(:day_of_month) # validates_numericality_of
  end
end

describe BillingCycle, "during updates" do
  before(:each) do
    @billing_cycle = Factory(:billing_cycle)
  end
  
  it "should allow updates" do
    @billing_cycle.name = "new name"
    @billing_cycle.day_of_month = 1
    
    @billing_cycle.should be_valid
    @billing_cycle.save!
    @billing_cycle.reload
    @billing_cycle.name.should eql("new name")
    @billing_cycle.day_of_month.should eql(1)
  end
  
  it "should not allow duplicate names" do
    Factory(:billing_cycle, :name => 'John')
    @billing_cycle.name = 'John'
    @billing_cycle.should_not be_valid
  end
  
  it "should not allow a string as day_of_month" do
    @billing_cycle.day_of_month = "string"
    @billing_cycle.should_not be_valid
  end
end

describe BillingCycle, "when loaded" do
  it "should have a name" do
    @billing_cycle = Factory(:billing_cycle, :name => "test name")
    @billing_cycle.reload
    @billing_cycle.name.should eql("test name")
  end
  
  it "should have customers" do
    @billing_cycle = Factory(:billing_cycle)
    # doing instantiation from customer side
    Factory(:customer, :billing_cycle => @billing_cycle)
    Factory(:customer, :billing_cycle => @billing_cycle)
    @billing_cycle.customers.size.should eql(2)
  end
end