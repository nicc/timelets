require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'test').should == users(:quentin)
  end

  it 'authenticates user' do
    User.authenticate('quentin', 'test').should == users(:quentin)
  end

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  
  describe "when new" do
  before(:each) do
    @user = User.new
  end

  it "should not be valid" do
    @user.should_not be_valid
  end
  
  it "should require a name" do
    @user.should have(1).error_on(:name)
  end
  
  it "should require an email address" do
    @user.should have_at_least(1).error_on(:email)
  end
  
  it "should require a point value" do
    @user.should have(1).error_on(:point_value)
  end
end

describe "when updated" do
  before(:each) do
    @user = Factory(:user)
  end
  
  it "should allow updates" do
    @user.name = "new name"
    @user.email = "new@email.com"
    @user.save!
    @user.should be_valid
    @user.name.should eql("new name")
    @user.email.should eql("new@email.com")
  end
  
  it "should not allow duplicate names" do
    Factory(:user, :name => "duplicate name")
    @user.name = "duplicate name"
    @user.should_not be_valid
    @user.should have(1).error_on(:name)
  end
  
  it "should not allow duplicate emails" do
    Factory(:user, :email => "duplicate@email.com")
    @user.email = "duplicate@email.com"
    @user.should_not be_valid
    @user.should have_at_least(1).error_on(:email)
  end
  
  it "should not allow invalid emails" do
    @user.email = "invalid@email"
    @user.should_not be_valid
    @user.should have_at_least(1).error_on(:email)
  end
end


describe "when loaded" do
  before(:each) do
    @user = Factory(:user, :point_value => 2)
    @user_effort1 = create_effort(:contract => Factory(:rate_contract),
                               :user => @user,
                               :start => Time.local(Time.today.year,Time.today.month,Time.today.day ,10,15,0),
                               :stop => nil,
                               :duration => 15.minutes.to_i,
                               :ticket_reference => "some ticket",
                               :name => "Effort Name",
                               :finished => true)
    @user_effort2 = create_effort(:contract => Factory(:rate_contract),
                               :user => @user,
                               :start => Time.local(Time.today.year,Time.today.month,Time.today.day ,11,0,0),
                               :stop => nil,
                               :duration => 30.minutes.to_i,
                               :ticket_reference => "some other ticket",
                               :name => "Effort Name 2",
                               :finished => true)
    @user_effort3 = create_effort(:contract => Factory(:rate_contract),
                               :user => @user,
                               :start => Time.local(Time.today.year,Time.today.month,Time.today.day ,12,0,0),
                               :stop => nil,
                               :duration => (1.hour + 30.minutes + 45.seconds).to_i,
                               :ticket_reference => "some other ticket",
                               :name => "Effort Name 2",
                               :finished => true)
    @other_user_effort = create_effort(:contract => Factory(:rate_contract),
                                    :user => Factory(:user),
                                    :start => Time.local(2008,"jan",1 ,11,0,0),
                                    :stop => nil,
                                    :duration => 1.hour.to_i,
                                    :ticket_reference => "some other ticket",
                                    :name => "Effort Name 2",
                                    :finished => true)
    @user_wrong_day = create_effort(:contract => Factory(:rate_contract),
                                   :user => @user,
                                   :start => Time.local(2008,"jan",1 ,12,0,0),
                                   :duration => (1.hour + 10.minutes + 45.seconds).to_i,
                                   :stop => nil,
                                   :ticket_reference => "some other ticket",
                                   :name => "Effort Name 2",
                                   :finished => true)
  end
  
  it "should have accessable attributes" do
    @user.name.should_not be_blank
    @user.email.should_not be_blank
    @user.point_value.should eql(2)
  end
  
  it "should have efforts" do
    @user.efforts.size.should eql(4)
    @user.efforts.should include(@user_effort1, @user_effort2, @user_effort3, @user_wrong_day)
    @user.efforts.should_not include(@other_user_effort)
  end
  
  it "should present it's daily total of time worked for today by default" do
    @user.time_worked.should eql((2.hours + 15.minutes + 45.seconds).to_i)
  end
  
  it "should present it's daily total of time worked for any day" do
    @user.time_worked(Time.local(2008,"jan",1 ,0,0,0)).should eql((1.hour + 10.minutes + 45.seconds).to_i)
  end
  
  it "should present it's daily efforts for today by default" do
    @user.daily_efforts.size.should eql(3)
    @user.efforts.should include(@user_effort1, @user_effort2, @user_effort3)
    @user.efforts.should_not include(@other_user_effort, @user_wrong_day)
  end
  
  it "should present it's daily efforts for any day" do
    @user.daily_efforts(Time.local(2008,"jan",1 ,0,0,0)).size.should eql(1)
    @user.daily_efforts(Time.local(2008,"jan",1 ,0,0,0)).should include(@user_wrong_day)
    @user.daily_efforts(Time.local(2008,"jan",1 ,0,0,0)).should_not include(@other_user_effort, @user_effort1, @user_effort2, @user_effort3)
  end
    
  it "should present what it's working on right now as an unfished task." do
    effort = create_effort(:user => @user, :stop => nil, :duration => nil, :finished => false)
    create_effort(:user => @user, :finished => true)
    @user.unfinished_effort.should eql(effort)
  end
end

  describe "effort allocation" do
    before(:each) do
      @effort_attributes = {:contract => Factory(:rate_contract),
                           :start => Time.local(2008,"jan",1 ,10,15,0),
                           :stop => Time.local(2008,"jan",1 ,10,30,0),
                           :duration => nil,
                           :billed_on => nil,
                           :ticket_reference => "some ticket",
                           :name => "Effort Name",
                           :hourly_point_value => nil,
                           :finished => true}
      @user = Factory(:user)
     
    end
    
    it "should be able to allocate finished efforts" do
      # I'm just testing that it calls the right things here, they're tested further in Effort Spec.
      @effort = Effort.new(@effort_attributes.merge(:user => @user))
      
      Effort.should_receive(:new).with(@effort_attributes.merge(:user => @user)).and_return(@effort)
      Effort.should_receive(:create_with_conflict_resolution).with(@effort)
      
      @user.assign_effort(@effort_attributes)
    end
    
    it "should be able to allocated an unfinished effort" do
      @effort = Effort.new(@effort_attributes.merge(:stop => nil, :duration => nil, :finished => false, :user => @user))
      
      Effort.should_receive(:new).with(@effort_attributes.merge(:stop => nil, :duration => nil, :finished => false, :user => @user)).and_return(@effort)
      
      @user.start_effort(@effort_attributes.merge(:stop => nil, :duration => nil, :finished => false))
      
      @user.unfinished_effort.should eql(@effort)
    end
    
    it "should be able to allocated an unfinished effort, with Time.now as default start" do
      time = Time.local(2008,"jan",1 ,10,30,0)
      Time.should_receive(:now).any_number_of_times.and_return(time)
      
      @user.start_effort(@effort_attributes.merge(:start => "", :stop => nil, :duration => nil, :finished => false))
      
      @user.unfinished_effort.start.should eql(time)
    end
    
    it "should be able to finish an unfinished effort" do
      @effort = Effort.create!(@effort_attributes.merge(:stop => nil, :duration => nil, :finished => false, :user => @user))
      time = Time.local(2008,"jan",1 ,10,30,0)
      @user.unfinished_effort.should eql(@effort)
      @user.finish_effort(time)
      @user.unfinished_effort.should eql(nil)
      @effort.reload
      @effort.finished.should eql(true)
      @effort.stop.to_s.should eql(time.to_s)
    end
  end
  
  describe "permissions" do
    before(:each) do
      @user = Factory(:user)
      @role1 = Factory(:role)
      @role2 = Factory(:role)
      @right1 = Factory(:right)
      @right2 =Factory(:right)
    end
    
    it "should have roles" do
      lambda { @user.roles = [@role1, @role2] }.should change(@user.roles, :size).by(2)
    end
    
    it "should have rights, via roles" do
      @role1.rights = [@right1]
      @role2.rights = [@right2]
      @user.roles = [@role1, @role2]
      
      @user.roles.collect{|role| role.rights }.flatten.size.should eql(2)
    end
    
    it "should authorize when it has permission" do
      @role1.rights = [@right1]
      @role2.rights = [@right2]
      @user.roles = [@role1, @role2]
      @user.should satisfy{ @user.has_permission?(@right1.controller, @right1.action) }
      @user.should satisfy{ @user.has_permission?(@right2.controller, @right2.action) }
    end
    
    it "should NOT authorize when it doesn't have permission" do
      @role1.rights = [@right1]
      @role2.rights = [@right2]
      @user.roles = [@role1]
      @user.should_not satisfy{ @user.has_permission?(@right2.controller, @right2.action) }
    end
  end

protected
  def create_user(options = {})
    record = User.new({ :name => 'squire', :point_value => '2', :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end

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