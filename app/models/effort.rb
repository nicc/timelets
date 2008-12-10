class Effort < ActiveRecord::Base
  validates_presence_of :name, :contract_id, :user_id, :hourly_point_value, :start
  validates_presence_of :stop, :duration, :if => :finished?
  
#  Doesn't seem to work with Ruby 1.8.5 which is latests stable on Debian Etch production server.
#  Entire plugin has been removed, it's the ActiveRecord extensions that break, not this meta-method call itself.
#  
#  ensures_immutability_of :start, :stop, :duration, :ticket_reference, :name, 
#                          :contract_id, :user_id, :hourly_point_value, :created_at, 
#                          :updated_at, :billed_on
  
  belongs_to :contract
  belongs_to :user
  
  def before_save
    self.start
    self.stop
    self.duration
  end
  
  def initialize(args={})
    super(check_integrity(args))
  end
  
  def start
    if self.finished?
      self.start = read_attribute(:start) || (self.stop - self.duration)
    else
      read_attribute(:start)
    end
  end
  
  def stop
    if self.finished?
      self.stop = read_attribute(:stop) || (self.start + self.duration)
    else
      read_attribute(:stop)
    end
  end
  
  def duration
    if self.finished?
      read = read_attribute(:duration)
      if read.nil? || read == 0
        self.duration = (self.stop - self.start).round
      else
        return read
      end
    else
      (Time.now - read_attribute(:start)).round
    end
  end

  
  # ----------------------------------------------------------------------------
  def self.create_with_conflict_resolution(new_effort)
    #begin
      Effort.transaction do     
        @efforts = resolve_conflicts_for(new_effort)  
        @efforts[:requested] = split_effort_accross_midnight(new_effort)
      end
      return @efforts
    #rescue
    #  return false
    #end
  end
  
  def finish(stop_time)
    Effort.transaction do
      self.stop = stop_time
      self.finished = true
      @efforts = Effort.resolve_conflicts_for(self)
      @efforts[:requested] = Effort.split_effort_accross_midnight(self)
      self.destroy if @efforts[:requested].size > 1
    end
    return @efforts
  end
 
  
  # ----------------------------------------------------------------------------
  private
  
  def self.resolve_conflicts_for(new_effort)
    efforts = {:created => [],
               :deleted => [] }
    [ lambda {|effort| lower_stop(efforts_to_lower_stop_for(effort), effort) },
      lambda {|effort| raise_start(efforts_to_raise_start_for(effort), effort)},
      lambda {|effort| split_efforts(efforts_to_split(effort), effort)},
      lambda {|effort| delete_efforts(efforts_to_delete(effort), effort)} 
    ].each do |function|
        array = function.call(new_effort)
        efforts[:created] += array[:created]
        efforts[:deleted] += array[:deleted]
    end
    return efforts
  end
  
  def self.split_effort_accross_midnight(new_effort)
    # Here split effort into 2 if over 2 days, pop into an array, and save iteratively over the array.
    # Stick the array in :requested.
    if new_effort.start.to_date != new_effort.stop.to_date
      new_efforts = []
      new_efforts << Effort.new(new_effort.attributes.merge("stop" => new_effort.stop.midnight, "duration" => nil))
      new_efforts << Effort.new(new_effort.attributes.merge("start" => new_effort.stop.midnight, "duration" => nil))
    else
      new_efforts = [new_effort]
    end
    new_efforts.each{|effort| effort.save! }
    new_efforts
  end
  
  def self.efforts_to_lower_stop_for(effort)   #1
    return Effort.find(:all, :conditions => [ "user_id = ? AND start < ? AND stop > ? AND stop <= ?",
                                                   effort.user_id, effort.start, effort.start, effort.stop ])
  end
  
  def self.efforts_to_raise_start_for(effort)   #2
    return Effort.find(:all, :conditions => [ "user_id = ? AND start >= ? AND start < ? AND stop > ?", 
                                                   effort.user_id, effort.start, effort.stop, effort.stop ])
  end
  
  def self.efforts_to_split(effort)   #3
    return Effort.find(:all, :conditions => [ "user_id = ? AND start < ? AND stop > ?", 
                                                 effort.user_id, effort.start, effort.stop ])
  end
  
  def self.efforts_to_delete(effort)   #4
    return Effort.find(:all, :conditions => [ "user_id = ? AND start >= ? AND stop <= ?", 
                                                 effort.user_id, effort.start, effort.stop ])
  end
  
  def self.lower_stop(efforts, new_effort)
    affected = { :created => [],
                 :deleted => [] }
    efforts.each do |effort|
      affected[:created] << Effort.create!(effort.attributes.merge("stop" => new_effort.start, "duration" => nil))
      affected[:deleted] << effort.destroy
    end
    return affected
  end
  
  def self.raise_start(efforts, new_effort)
    affected = { :created => [],
                 :deleted => [] }
    efforts.each do |effort|
      affected[:created] << Effort.create!(effort.attributes.merge("start" => new_effort.stop, "duration" => nil))
      affected[:deleted] << effort.destroy
    end
    return affected
  end
  
  def self.split_efforts(efforts, new_effort)
    affected = { :created => [],
                 :deleted => [] }
    efforts.each do |effort|
      affected[:created] << Effort.create!(effort.attributes.merge("stop" => new_effort.start, "duration" => nil))
      affected[:created] << Effort.create!(effort.attributes.merge("start" => new_effort.stop, "duration" => nil))
      affected[:deleted] << effort.destroy
    end
    return affected
  end
  
  def self.delete_efforts(efforts, new_effort)
    affected = { :created => [],
                 :deleted => [] }
    efforts.each do |effort|
      affected[:deleted] << effort.destroy
    end
    return affected
  end
  
  def check_integrity(args = {})
    args.symbolize_keys!
    
    user = User.find(args[:user_id] || args[:user])
    args[:hourly_point_value] ||= user.point_value
    
    unless value_to_boolean(args[:finished])
      raise "Cannot provide stop or duration for an unfinished effort." if !args[:stop].nil? || !args[:duration].nil?
      raise "User cannot have more than one unfinished effort at a time." if user.unfinished_effort
    end
    
    count = 0
    count += 1 unless args[:start].blank?
    count += 1 unless args[:stop].blank?
    count += 1 unless args[:duration].blank?
    raise "you must provide at least 2 time references (start, stop or duration)" unless count >= 2 || args[:finished].blank?
    if count == 3 && args[:finished]
      raise "The supplied duration does not match start/stop values!" unless args[:stop].to_time - args[:start].to_time == args[:duration].to_i
    end
    
    if (!args[:start]).blank? && !(args[:stop]).blank?
      raise "Start time cannot be greater than stop time" if args[:start] > args[:stop]
      raise "Start and stop times cannot be equal" if args[:start] == args[:stop]
    end
    
    return args
  end
  
  def value_to_boolean(value)
    if value == true || value == false
      value
    else
      %w(true t 1).include?(value.to_s.downcase)
    end
  end


end
