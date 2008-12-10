class OverviewsController < ApplicationController
  include DateSelection
  
  def index
    get_date
    get_user
    @selected_user ? get_efforts(@selected_user) : @todays_efforts = []
    @users = User.find(:all, :order => :name)
  end
  
  def select_user
    get_date
    if params[:user].blank?
      @todays_efforts = []
      session[:user_overview] = nil
    else
      @selected_user = User.find(params[:user])
      session[:user_overview] = params[:user]
      get_efforts(@selected_user)
    end
  end
  
  protected
  def authorized?
    super && @current_user.has_permission?( self.class.controller_path, action_name )
  end
  
  def get_user
    session[:user_overview] ? @selected_user = User.find(session[:user_overview]) : @selected_user = nil
  end
  
end
