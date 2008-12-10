class Fixnum
  def to_time_interval
    phrases = []
    [ { :unit => "d", :seconds => 3600 * 24 },
      { :unit => "h", :seconds => 3600 },
      { :unit => "m", :seconds => 60 },
      { :unit => "s", :seconds => 1 }
    ].inject(self) do |remainder, options|
      phrase, remainder = take_time(remainder, options)
      phrases << phrase if phrase
      remainder
    end
    phrases.join(" ") || "0 seconds"
  end

  private

  def take_time(from, options)
    quotient = from / options[:seconds]
    remainder = from % options[:seconds]
    phrase = quotient > 0 ? "#{quotient}#{options[:unit]}" : nil
    [phrase, remainder]
  end
  
end