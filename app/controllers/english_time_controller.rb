class EnglishTimeController < ApplicationController
  #
  # Apply the patches for Chronic availalble at 
  #   http://rubyforge.org/tracker/index.php?func=detail&aid=7487&group_id=2115&atid=8245
  # They will fix the bug of 2007-01-01 00:00:00 being translated as 2007-01-02 00:00:00 
  #
  
  TIMEFORMAT = '%Y-%m-%d (%A %d %B)'
  ISODATEFORMAT = '%Y-%m-%d'
  FULLTIMEFORMAT = '%Y-%m-%d at %H:%M:%S'
  ISOFULLTIMEFORMAT = '%Y-%m-%d %H:%M:%S'
  
  def full_time
    #raise params.inspect
    @time = Chronic.parse(params[:input_time], :context => :past)
    @time_formated = @time.nil? ? nil : @time.strftime(FULLTIMEFORMAT)
    
    update_div = "display_#{params[:model]}_#{params[:method]}"
    hidden_id = "#{params[:model]}_#{params[:method]}"

    render :update do |page|
      page.replace_html update_div.to_sym, @time_formated || "<br/>"
      page.visual_effect :highlight, update_div.to_sym, :duration => 0.5
    end
  end
  
end
