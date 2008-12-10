require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PointContract do
  describe "when new" do
    before(:each) do
      @contract = PointContract.new
    end

    it "should not be valid" do
      @contract.should_not be_valid
    end

    # Applies to both PointContract and RateContract
    it "should require indication of whether retainer includes afterhours work" do
      @contract.should have_at_least(1).error_on(:retainer_includes_ah)
    end

    # Applies to both PointContract and RateContract
    it "should require a customer association" do
      @contract.should have_at_least(1).error_on(:customer_id)
    end

    # Applies to both PointContract and RateContract
    it "should require a name" do
      @contract.should have_at_least(1).error_on(:name)
    end

    it "should require a point rate" do
      @contract.should have_at_least(1).error_on(:point_rate)
    end

    it "should require an afterhours point adjustment" do
      @contract.should have_at_least(1).error_on(:ah_point_adjustment)
    end

    it "should require retainer points" do
      @contract.should have_at_least(1).error_on(:retainer_points)
    end
  end


  describe "when updated" do
    before(:each) do
      @contract = Factory(:point_contract)
    end

    it "should allow updates" do
      new_values = { :point_rate => 255,
                     :ah_point_adjustment => 2,
                     :retainer_includes_ah => true,
                     :customer => Factory(:customer),
                     :name => "new name",
                     :description => "new description" }

      new_values.each_pair {|key, value| @contract[key] = value  }
      @contract.save!
      new_values.each_pair {|key, value| @contract[key].should eql(value) }
    end

    it "should not allow duplicate names" do
      Factory(:point_contract, :name => "duplicate name")
      @contract.name = "duplicate name"
      @contract.should have_at_least(1).error_on(:name)
    end
  end

  describe "when loaded" do
    it "should have a name" do
      @contract = Factory(:point_contract, :name => "super awesome point contract")
      @contract.name.should eql("super awesome point contract")
    end

    it "should have a customer" do
      @contract = Factory(:point_contract)
      @contract.customer.should be_an_instance_of(Customer)
    end

    it "should have efforts" do
      @contract = Factory(:point_contract)
      @effort1 = create_effort(:contract => @contract,
                                :user => Factory(:user),
                                :start => Time.local(2008,"jan",1 ,10,15,0),
                                :stop => nil,
                                :duration => 15.minutes.to_i,
                                :ticket_reference => "some ticket",
                                :name => "Effort1 Name")
      @effort2 = create_effort(:contract => @contract,
                                :user => Factory(:user),
                                :start => Time.local(2008,"jan",5 ,10,15,0),
                                :stop => Time.local(2008,"jan",5 ,12,45,13),
                                :ticket_reference => "some other ticket",
                                :name => "Effort2 Name")
      @effort3 = create_effort(:contract => @contract,
                                :user => Factory(:user),
                                :stop => Time.local(2008,"jan",3 ,12,45,13),
                                :start => nil,
                                :duration => 76.minutes.to_i,
                                :ticket_reference => "some other ticket",
                                :name => "Effort3 Name")
      @diff_contract = create_effort(:contract => Factory(:point_contract),
                                      :user => Factory(:user),
                                      :stop => Time.local(2008,"jan",3 ,12,45,13),
                                      :start => nil,
                                      :duration => 76.minutes.to_i,
                                      :ticket_reference => "some other ticket",
                                      :name => "Effort3 Name")

      @contract.efforts.size.should eql(3)
      @contract.efforts.should include(@effort1, @effort2, @effort3)
      @contract.efforts.should_not include(@diff_contract)
    end
  end


  protected

  def create_effort(options = {})
    options.symbolize_keys!
    effort = Effort.create!({ :contract => Factory(:rate_contract),
                              :user => Factory(:user),
                              :start => Time.local(2008,"jan",1 ,10,15,0),
                              :stop => Time.local(2008,"jan",1 ,10,30,0),
                              :duration => nil,
                              :billed_on => nil,
                              :ticket_reference => "some ticket",
                              :name => "Effort Name",
                              :hourly_point_value => nil,
                              :finished => true }.merge(options) )
    effort
  end
end