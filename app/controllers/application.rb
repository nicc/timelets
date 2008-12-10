# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  require 'chronic'
  require 'chronic_extensions'
  
  helper :all # include all helpers, all the time
  
  # Enter stage left: restful_authentication system
  before_filter :login_required

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '397007584ed88457f4349378aed9fa10'
  
  protected
  def get_efforts(user)
    @todays_efforts = user.daily_efforts(Time.local(@year, @month, @day))
  end
end
