require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  describe "being created" do
    
    before(:each) do
      @creating_role = Proc.new do
        @role = Factory(:role)
        violated "#{@role.errors.full_messages.to_sentence}" if @role.new_record?
      end

    end

    it "should increment Role#count" do
      @creating_role.should change(Role, :count).by(1)
    end

    it "should require name" do
      lambda do
        r = Factory.build(:role, :name => nil)
        r.save
        r.errors.on(:name).should_not be_nil
      end.should_not change(Role, :count)
    end
    
    it "should allow user associations" do
      r = Factory(:role)
      u = Factory(:user)
      u.roles = [r]
      r.users.size.should eql(1)
    end
    
  end
end
