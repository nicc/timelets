require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EffortsController do
  fixtures :users
  
  def check_layout
    # They should all use with_timeline layout.
    response.should use_layout('application')  # Custom matcher.  See /spec/matchers/*.rb
  end
    
  describe "index" do
    after(:each) do
      check_layout
    end
    
    def get_index
      get :index, {}, {:user_id => 1}
    end
    
    it "should assign the required instance variables" do
      all_customers = [Factory(:customer), Factory(:customer)]
      Customer.should_receive(:find).with(:all).and_return(all_customers)
      user = Factory(:user)
      User.should_receive(:find_by_id).with(1).and_return(user)
      efforts = [mock_model(Effort), mock_model(Effort), mock_model(Effort)]
      user.should_receive(:daily_efforts).and_return(efforts)
      get_index
      check_date_selection
      assigns(:customers).should eql(all_customers)
      assigns(:todays_efforts).should equal(efforts)
    end
    
    it "should load up any unfinished efforts for the timer form" do  #urgh... not fun.
      user = Factory(:user)
      User.should_receive(:find_by_id).with(1).and_return(user)
      effort = mock_model(Effort)
      user.should_receive(:unfinished_effort).and_return(effort)
      contract = mock_model(PointContract)
      effort.should_receive(:contract).and_return(contract)
      customer = mock_model(Customer)
      contract.should_receive(:customer).and_return(customer)
      customer.should_receive(:contracts).and_return([mock_model(PointContract, :id => 1, :name => "one"), mock_model(PointContract, :id => 2, :name => "two")])
      get_index
      assigns(:current_user).should equal(user)
      assigns(:customer).should equal(customer)
      assigns(:contracts_options).should eql([ ["one", 1], ["two", 2] ])
    end
    
  end
  
  describe "create" do
    before(:each) do
      @effort_params = {"contract_id" => 1, "name" => 'afdshjk', "ticket_reference" => "", 
                     "duration" => "", "start" => "10 minutes ago", "finished" => true, "stop" => 'now'}
    end
    
    def do_post(params={})
      post :create, {:assigned_effort => @effort_params.merge(params)}, {:user_id => 1}
    end
    
    it "should assign an effort" do
      @current_user = Factory(:user)
      User.should_receive(:find_by_id).with(1).and_return(@current_user)
      Chronic.should_receive(:datetime_string).with("10 minutes ago", :context => :past).and_return("10 minutes ago")
      Chronic.should_receive(:datetime_string).with("now", :context => :past).and_return("now")
      @current_user.should_receive(:assign_effort)
      do_post
      response.should be_success
      assigns(:current_user).should equal(@current_user)
    end
    
    it "should redirect on failed create" do
      do_post("stop" => nil, "duration" => nil)
      response.should be_success
    end
  end
  
  describe "show" do
    it "should assign the effort to be viewed" do
      effort = mock_model(Effort)
      Effort.should_receive(:find).with("1").and_return(effort)
      get :show, {:id => 1}, {:user_id => 1}
      assigns(:effort).should equal(effort)
    end
    
  end
  
  describe "breakdown" do
    it "should assign the relevant instance variables" do
      @current_user = Factory(:user)
      User.should_receive(:find_by_id).with(1).and_return(@current_user)
      effort = mock_model(Effort)
      @current_user.should_receive(:unfinished_effort).and_return(effort)
      get :breakdown, {}, {:user_id => 1}
      check_date_selection
      assigns(:timed_effort).should equal(effort)
    end
  end
  
  describe "select_customer" do
    it "should set the relevant instance variables" do
      customer = mock_model(Customer)
      Customer.should_receive(:find).with("1").and_return(customer)
      contracts = [mock_model(Contract), mock_model(Contract), mock_model(Contract)]
      customer.should_receive(:contracts).and_return(contracts)
      post :select_customer, {:effort_customer => 1 }, {:user_id => 1}
      assigns(:contracts).should equal(contracts)
    end
  end
  
  describe "start_effort" do
    before(:each) do
      @effort_params = {"contract_id" => "1", "name" => 'afdshjk', "ticket_reference" => "", 
                     "duration" => "", "start" => "10 minutes ago"}
    end
    
    def do_post
      post( :start_effort, { :effort_customer => "1", :timed_effort => @effort_params }, {:user_id => 1} )
    end
    
    it "should parse date parameters" do
      Chronic.should_receive(:datetime_string).with("10 minutes ago", :context => :past).and_return("10 minutes ago")
      do_post
    end
    
    it "should load up customers for the forms" do
      customers = [mock_model(Customer), mock_model(Customer), mock_model(Customer)]
      Customer.should_receive(:find).with(:all).and_return(customers)
      do_post
      assigns(:customers).should equal(customers)
    end
    
    it "should load chosen customer & contracts options for form" do
      customer = mock_model(Customer)
      contracts = [mock_model(Contract, :name => "one", :id => 1), mock_model(Contract, :name => "two", :id => 2)]
      Customer.should_receive(:find).with(:all)  # Just to get past the initial call so as to get to test the next one.
      Customer.should_receive(:find).with("1").and_return(customer)
      customer.should_receive(:contracts).and_return(contracts)
      do_post
      assigns(:customer).should equal(customer)
      assigns(:contracts_options).should eql([ ["one", 1], ["two", 2] ])
    end
    
    it "should start an effort, and assign result to @timed_effort" do
      customer = mock_model(Customer)
      contracts = [mock_model(Contract, :name => "one", :id => 1), mock_model(Contract, :name => "two", :id => 2)]
      Customer.should_receive(:find).with(:all)  # Just to get past the initial call so as to get to test the next one.
      Customer.should_receive(:find).with("1").and_return(customer)
      customer.should_receive(:contracts).and_return(contracts)
      current_user = mock_model(User)
      unfinished_effort = mock_model(Effort)
      User.should_receive(:find_by_id).with(1).and_return(current_user)
      current_user.should_receive(:start_effort).and_return(unfinished_effort)
      do_post
      assigns(:timed_effort).should equal(unfinished_effort)
    end
  end
  
  describe "finish_effort" do
    before(:each) do
      @current_user = mock_model(User)
      User.should_receive(:find_by_id).with(1).and_return(@current_user)
      @effort = mock_model(Effort)
      @current_user.should_receive(:unfinished_effort).and_return(@effort)
      
      contract = mock_model(RateContract)
      customer = mock_model(Customer)
      contracts = [mock_model(RateContract, :name => "one", :id => 1), mock_model(RateContract, :name => "two", :id => 2)]
      @effort.stub!(:contract).and_return(contract)
      contract.stub!(:customer).and_return(customer)
      customer.stub!(:contracts).and_return(contracts)
    end
    
    def do_post
      post( :finish_effort, { :effort_customer => "1", :timed_effort => {"stop" => "10 minutes ago"} }, {:user_id => 1} )
    end
    
    it "should parse date parameters" do
      Chronic.should_receive(:datetime_string).with("10 minutes ago", :context => :past)
      do_post
    end
    
    it "should load all customers" do
      customers = [mock_model(Customer), mock_model(Customer)]
      Customer.should_receive(:find).with(:all).and_return(customers)
      do_post
      assigns(:customers).should equal(customers)
    end
    
    it "should call finish_effort and set results to @results" do
      results_hash = {:some => "hash"}
      @current_user.should_receive(:finish_effort).and_return(results_hash)
      do_post
      assigns(:results).should equal(results_hash)
    end
    
  end
  
  describe "check_unfinished_duration" do
    it "should should assign the unfinished effort for rjs template" do
      @current_user = mock_model(User)
      User.should_receive(:find_by_id).with(1).and_return(@current_user)
      @effort = mock_model(Effort)
      @current_user.should_receive(:unfinished_effort).and_return(@effort)
      post :check_unfinished_duration, {}, {:user_id => 1}
      assigns(:current_effort).should equal(@effort)
    end
  end
  
  describe "cancel_unfinished_effort" do
    it "should assign all customers for form" do
      customers = [mock_model(Customer), mock_model(Customer)]
      Customer.should_receive(:find).with(:all).and_return(customers)
      post :cancel_unfinished_effort, {}, {:user_id => 1}
      assigns(:customers).should equal(customers)
    end
    
    it "should destroy the current user's unfinshed effort" do
      @current_user = mock_model(User)
      User.should_receive(:find_by_id).with(1).and_return(@current_user)
      @effort = mock_model(Effort)
      @current_user.should_receive(:unfinished_effort).twice.and_return(@effort)  # Twice cos it checks existence first
      @effort.should_receive(:destroy)
      post :cancel_unfinished_effort, {}, {:user_id => 1}
    end
    
  end
  
  describe "set_month" do
    before(:each) do
      @current_user = Factory(:user)
    end
    
    def do_post(opts={})
      # Not checking valid keys for now.  If you gimme something I dont use, tough.
      post :set_month, {:month => "2"}.merge(opts[:params] || {}), {:user_id => @current_user.id}.merge(opts[:session] || {})
    end
    
    it "should set selected_month in session to the month param (as integer)" do
      do_post(:params => {:month => "2"})  # being explicit for clarity
      session[:selected_month].should eql(2)
    end
    
    it "should get the date" do
      do_post(:params => {:month =>"2"})  # being explicit for clarity
      check_date_selection(:month => "2")
    end
    
    describe "when called from an efforts view" do
      it "should get @todays_efforts for the current user" do
        User.should_receive(:find_by_id).with(@current_user.id).and_return(@current_user)
        efforts = [mock_model(Effort), mock_model(Effort), mock_model(Effort)]
        @current_user.should_receive(:daily_efforts).and_return(efforts)
        do_post(:params => {:and_then => 'efforts_index'})
        assigns(:todays_efforts).should equal(efforts)
      end
    end
    
    describe "when called from an overviews view" do
      describe "when a user overview is selected" do
        it "should load up @selected_user" do
          user = Factory(:user)
          User.should_receive(:find).with(user.id.to_s).and_return(user)
          do_post(:params => {:and_then => 'overviews_index'}, :session => {:user_overview => user.id.to_s})
          assigns(:selected_user).should equal(user)
        end
        
        it "should get @todays_efforts for selected user" do
          user = Factory(:user)
          efforts = [mock_model(Effort), mock_model(Effort), mock_model(Effort)]
          User.should_receive(:find).with(user.id.to_s).and_return(user)
          user.should_receive(:daily_efforts).and_return(efforts)
          do_post(:params => {:and_then => 'overviews_index'}, :session => {:user_overview => user.id.to_s})
          assigns(:todays_efforts).should equal(efforts)
        end
      end
      
      describe "when a user overview is NOT selected" do
        it "should set @todays_efforts to an empty array" do
          do_post(:params => {:and_then => 'overviews_index'})
          assigns(:todays_efforts).should eql([])
        end
      end
    end
  end
  
  describe "set_day" do
    before(:each) do
      @current_user = Factory(:user)
    end
    
    def do_post(opts={})
      # Not checking valid keys for now.  If you gimme something I dont use, tough.
      post :set_day, {:day => "2"}.merge(opts[:params] || {}), {:user_id => @current_user.id}.merge(opts[:session] || {})
    end
    
    it "should set selected_day in session to the day param (as integer)" do
      do_post(:params => {:day => "2"})  # being explicit for clarity
      session[:selected_day].should eql(2)
    end
    
    it "should get the date" do
      do_post(:params => {:day =>"2"})  # being explicit for clarity
      check_date_selection(:day => "2")
    end
    
    it "should render the template reflected in :and_then param" do
      do_post(:params => {:and_then => 'overviews_index'})
      response.should render_template('efforts/overviews_index_set_day.rjs')
    end
      
    describe "when called from an efforts view" do
      it "should get @todays_efforts for the current user" do
        User.should_receive(:find_by_id).with(@current_user.id).and_return(@current_user)
        efforts = [mock_model(Effort), mock_model(Effort), mock_model(Effort)]
        @current_user.should_receive(:daily_efforts).and_return(efforts)
        do_post(:params => {:and_then => 'efforts_index'})
        assigns(:todays_efforts).should equal(efforts)
      end
    end
    
    describe "when called from an overviews view" do
      describe "when a user overview is selected" do
        it "should load up @selected_user" do
          user = Factory(:user)
          User.should_receive(:find).with(user.id.to_s).and_return(user)
          do_post(:params => {:and_then => 'overviews_index'}, :session => {:user_overview => user.id.to_s})
          assigns(:selected_user).should equal(user)
        end
        
        it "should get @todays_efforts for selected user" do
          user = Factory(:user)
          efforts = [mock_model(Effort), mock_model(Effort), mock_model(Effort)]
          User.should_receive(:find).with(user.id.to_s).and_return(user)
          user.should_receive(:daily_efforts).and_return(efforts)
          do_post(:params => {:and_then => 'overviews_index'}, :session => {:user_overview => user.id.to_s})
          assigns(:todays_efforts).should equal(efforts)
        end
      end
      
      describe "when a user overview is NOT selected" do
        it "should set @todays_efforts to an empty array" do
          do_post(:params => {:and_then => 'overviews_index'})
          assigns(:todays_efforts).should eql([])
        end
      end
    end
  end

end