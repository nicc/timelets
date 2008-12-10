require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  fixtures :users
  
  #  Just tests create user.  No public signup allowed.  Authenticated user in session for post.
  it 'allows create user' do 
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end


  

  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  
  # Has user in session.  No public signup allowed.
  def create_user(options = {})
    post :create, {:user => { :name => 'quire', :point_value => "2", :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)}, {:user_id => "1"}
  end
end