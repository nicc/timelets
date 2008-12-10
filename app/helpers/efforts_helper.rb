module EffortsHelper
  
  def remote_function(options)

    unless options[:spinner] == false
      options[:before] = "Element.show('spinner')" + (("; #{options[:before]}" if options[:before]) || "")
      options[:complete] = (("#{options[:complete]}; " if options[:complete]) || "") + "Element.hide('spinner')"
    end
    
    super(options)
  end
  
end
