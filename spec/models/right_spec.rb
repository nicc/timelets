require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Right do
  describe "being created" do
    
    before(:each) do
      @creating_right = Proc.new do
        @right = Factory(:right)
        violated "#{@right.errors.full_messages.to_sentence}" if @right.new_record?
      end

    end

    it "should increment Right#count" do
      @creating_right.should change(Right, :count).by(1)
    end

    it "should require name" do
      lambda do
        r = Factory.build(:right, :name => nil)
        r.save
        r.errors.on(:name).should_not be_nil
      end.should_not change(Right, :count)
    end
    
    it "should require controller" do
      lambda do
        r = Factory.build(:right, :controller => nil)
        r.save
        r.errors.on(:controller).should_not be_nil
      end.should_not change(Right, :count)
    end
    
    it "should require action" do
      lambda do
        r = Factory.build(:right, :action => nil)
        r.save
        r.errors.on(:action).should_not be_nil
      end.should_not change(Right, :count)
    end
    
    it "should allow role associations" do
      right = Factory(:right)
      role = Factory(:role)
      right.roles = [role]
      right.roles.size.should eql(1)
    end
    
  end
end
