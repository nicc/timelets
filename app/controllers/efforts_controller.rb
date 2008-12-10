class EffortsController < ApplicationController 
  include DateSelection
  
  def index
    get_date
    get_efforts(@current_user)
    @customers = Customer.find(:all)
    @timed_effort = @current_user.unfinished_effort
    if @timed_effort
      @customer = @timed_effort.contract.customer
      @contracts_options = @customer.contracts.collect{|c| [c.name, c.id] }
    end
  end
  
  def create
    parse_date_parameters('assigned')
    @customers = Customer.find(:all)
    params[:assigned_effort][:duration] = params[:assigned_effort][:duration].to_i * 60 unless params[:assigned_effort][:duration].blank?
    begin
      @results = @current_user.assign_effort(params[:assigned_effort])
      get_date
      get_efforts(@current_user)
    rescue
      render :action => 'failed_create'
    end
  end
  
  def show
    @effort = Effort.find(params[:id])
    render :template => 'shared/show'
  end
  
  def breakdown
    get_date
    get_efforts(@current_user)
    @timed_effort = @current_user.unfinished_effort
  end
  
  def select_customer
    unless params[:effort_customer].blank?
      customer = Customer.find(params[:effort_customer])
      @contracts = customer.contracts
    end
  end
  
  def start_effort
    parse_date_parameters('timed')
    @customers = Customer.find(:all)
    begin
      @customer = Customer.find(params[:effort_customer])
      @contracts_options = @customer.contracts.collect{|c| [c.name, c.id] }
      if params[:timed_effort][:start].blank?
        params[:timed_effort][:start] = Time.now
      end
      @timed_effort = @current_user.start_effort(params[:timed_effort])
    rescue
      render :action => 'failed_start'
    end
  end
  
  def finish_effort
    parse_date_parameters('timed')
    @customers = Customer.find(:all)
    effort = @current_user.unfinished_effort
    begin
      if params[:timed_effort][:stop].blank?
        params[:timed_effort][:stop] = Time.now
      end
      @results = @current_user.finish_effort(params[:timed_effort][:stop])
      get_date
      get_efforts(@current_user)
    rescue
      @timed_effort = effort
      @customer = @timed_effort.contract.customer
      @contracts_options = @customer.contracts.collect{|c| [c.name, c.id] }
      render :action => 'failed_finish'
    end
  end
  
  def check_unfinished_duration
    @current_effort = @current_user.unfinished_effort
  end
  
  def cancel_unfinished_effort
    @current_user.unfinished_effort.destroy if @current_user.unfinished_effort
    @customers = Customer.find(:all)
  end
  
  #TODO: Algorythmic stuff could be replaced with a strategy pattern.  
  #      params[:and_then] could be renamed and expanded to denote a 
  #      strategy for getting efforts, setting users etc..
  def set_month 
    session[:selected_month] = params[:month].to_i
    get_date
    if params[:and_then] == 'overviews_index'
      if session[:user_overview].blank?
        @todays_efforts = []
      else
        @selected_user = User.find(session[:user_overview])
        get_efforts(@selected_user)
      end
    else
      get_efforts(@current_user)
    end
  end
  
  #TODO: Algorythmic stuff could be replaced with a strategy pattern.  
  #      params[:and_then] could be renamed and expanded to denote a 
  #      strategy for getting efforts, setting users etc..
  def set_day
    session[:selected_day] = params[:day].to_i
    get_date
    if params[:and_then] == 'overviews_index'
      if session[:user_overview].blank?
        @todays_efforts = []
      else
        @selected_user = User.find(session[:user_overview])
        get_efforts(@selected_user)
      end
    else
      get_efforts(@current_user)
    end
    render :template => "efforts/#{params[:and_then]}_set_day.rjs"
  end
  
  
  private
  # def get_efforts(user)   See application controller
  
  def parse_date_parameters(prefix)
    return if params["#{prefix}_effort".to_sym].nil? 
    params["#{prefix}_effort".to_sym][:start] = Chronic.datetime_string(params["#{prefix}_effort".to_sym][:start], :context => :past) unless params["#{prefix}_effort".to_sym][:start].blank?
    params["#{prefix}_effort".to_sym][:stop] = Chronic.datetime_string(params["#{prefix}_effort".to_sym][:stop], :context => :past) unless params["#{prefix}_effort".to_sym][:stop].blank?
  end
end
