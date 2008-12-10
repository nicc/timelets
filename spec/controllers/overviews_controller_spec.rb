require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

  def check_layout
    # They should all use with_timeline layout.
    response.should use_layout('application')  # Custom matcher.  See /spec/matchers/*.rb
  end
   
describe OverviewsController do
  before(:each) do
    @user = Factory(:user)
  end

  describe "permissions" do
    it "should allow authorized action calls" do
      @user.gimme_the_right(:overviews, :index)
      
      get :index, {}, {:user_id => @user.id}
      response.should be_success
    end
   
    it "should not allow unauthorized action calls" do
      get :index, {}, {:user_id => @user.id}
      response.should be_redirect
    end
  end
 
  describe "index" do
    before(:each) do
      @user.gimme_the_right(:overviews, :index)
    end
    
    def do_get(session_values={}) #TODO: Hasherize the params to do_get and do_post to avoid ambiguity wrt params and session.
      get :index, {}, {:user_id => @user.id}.merge(session_values)
    end
    
    it "should use the with_timeline layout" do
      do_get
      check_layout
    end
    
    it "should load up default date selection" do
      do_get
      check_date_selection
    end
    
    it "should load up all users" do
      users = [Factory(:user), Factory(:user), Factory(:user)]
      User.should_receive(:find).with(:all, {:order=>:name}).and_return(users)
      do_get
      assigns(:users).should equal(users)
    end
    
    describe "when selected user is in session" do
      it "should load up the selected user" do
        user = Factory(:user)
        do_get(:user_overview => user.id.to_s)
        assigns(:selected_user).should eql(user)
      end
      
      it "should load up todays_efforts for the selected user" do
        user = Factory(:user)
        efforts = [mock_model(Effort), mock_model(Effort), mock_model(Effort)]
        User.stub!(:find).and_return(user)
        user.should_receive(:daily_efforts).and_return(efforts)
        do_get(:user_overview => user.id.to_s)
        assigns(:todays_efforts).should equal(efforts)
      end
    end
    
    describe "when selected user is NOT in session" do
      it "should not load a selected user" do
        do_get
        assigns(:selected_user).should be_nil
      end
      
      it "should load up todays_efforts as an empty array" do
        do_get
        assigns(:todays_efforts).should eql([])
      end
    end
    
  end
  
  
  describe "select_user" do
    before(:each) do
      @user.gimme_the_right(:overviews, :select_user)
    end
    
    def do_post(params={}) #TODO: Hasherize the params to do_get and do_post to avoid ambiguity wrt params and session.
      post :select_user, {}.merge(params), {:user_id => @user.id}
    end
    
    describe "when selecting user" do
      it "should load up @selected_user as the user selected" do
        user = Factory(:user)
        User.should_receive(:find).with(user.id.to_s).and_return(user)
        do_post(:user => user.id.to_s)
        assigns[:selected_user].should eql(user)
      end
      
      it "should set the user_overview session variable to the selected user's id" do
        user = Factory(:user)
        User.should_receive(:find).with(user.id.to_s).and_return(user)
        do_post(:user => user.id.to_s)
        session[:user_overview].should eql(user.id.to_s)
      end
      
      it "should load up the selected user's @todays_efforts"do
        user = Factory(:user)
        efforts = [mock_model(Effort), mock_model(Effort), mock_model(Effort)]
        User.should_receive(:find).with(user.id.to_s).and_return(user)
        user.should_receive(:daily_efforts).and_return(efforts)
        do_post(:user => user.id.to_s)
        assigns(:todays_efforts).should eql(efforts)
      end
    end
    
    describe "when deselecting user" do
      it "should set @todays_efforts to an empty array" do
        do_post(:user => "")
        assigns(:todays_efforts).should eql([])
      end
      
      it "should set the user_overview session variable to nil" do
        do_post(:user => "")
        session[:user_overview].should be_nil
      end
    end
  end

end