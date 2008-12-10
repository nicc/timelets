module Chronic
  class << self
	  def date_string(date_string, options={})
	    date = Chronic.parse(date_string, options)
	    date.nil? ? date_string : date.strftime(EnglishTimeController::ISODATEFORMAT)
	  end
          
          def datetime_string(date_string, options={})
	    date = Chronic.parse(date_string, options)
	    date.nil? ? date_string : date.strftime(EnglishTimeController::ISOFULLTIMEFORMAT)
	  end
	end
end