# This module handles date selection in session for timeline calendar.  Shared by controllers.
module DateSelection
  
  def set_month
    raise NoMethodError, "You need to overload this method in the controller using it.  
                          Getting efforts after date selection is implementation-specific.
                          Think of it as an interface method."
  end
  
  def set_day
    raise NoMethodError, "You need to overload this method in the controller using it.  
                          Getting efforts after date selection is implementation-specific.
                          Think of it as an interface method."
  end
  
  protected
    def get_date
      now = Time.now
      @day = session[:selected_day] || now.day
      @month = session[:selected_month] || now.month
      @year = session[:selected_year] || now.year
      @selected_date = Time.local(@year, @month, @day)
    end
end