# TODO: Note... can't use Factory Girl for Efforts because it does Object Builder,
#       and Effort class does not allow instantiation of invalid objects.  As a result,
#       the object instantiation for tests is very verbose and not at all DRY.


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Effort, "when new" do
  before(:each) do
    @effort = new_effort(:start => Time.local(2008,"jan",1 ,10,15,0),
                         :stop => Time.local(2008,"jan",1 ,10,30,0),
                         :duration => 15.minutes.to_i,
                         :billed_on => nil,
                         :ticket_reference => "some ticket",
                         :hourly_point_value => nil,
                         :user => Factory(:user), 
                         :name => nil, 
                         :contract => nil)
  end   

  it "should not be valid" do
    @effort.should_not be_valid
  end
  
  it "should require a name" do
    @effort.should have_at_least(1).error_on(:name)
  end
  
  it "should require a contract association" do
    @effort.should have_at_least(1).error_on(:contract_id)
  end
end


describe Effort, "time calculations" do
  describe "when start and stop are provided" do
    before(:each) do
      @effort = new_effort(:start => Time.local(2008,"jan",1 ,10,15,0), :stop => Time.local(2008,"jan",1,12,45,20), :duration => nil )
    end

    it "should calculate it's duration correctly" do
      @effort.duration.should eql(9020) # 2 hours, 30 minutes and 20 seconds
    end
    
    it "should store the duration when saved" do
      @effort.save!
      @effort.reload
      @effort.attributes["duration"].should eql(9020)  # Getting from db
    end

  end

  describe "when start and duration are provided" do
    before(:each) do
      @effort = new_effort(:start => Time.local(2008,"jan",1 ,10,15,0), :duration => 4534, :stop => nil ) # 1 hour, 15 minutes and 34 seconds
    end

    it "should calculate it's stop time correctly" do
      @effort.stop.should eql(Time.local(2008,"jan",1 ,11,30,34))
    end
    
    it "should store the stop time when saved" do
      @effort.save!
      @effort.reload
      @effort.attributes["stop"].should eql(Time.local(2008,"jan",1 ,11,30,34))  # Getting from db
    end

  end

  describe "when stop and duration are provided" do
    before(:each) do
      @effort = new_effort(:stop => Time.local(2008,"jan",1 ,10,15,0), :duration => 4534, :start => nil ) # 1 hour, 15 minutes and 34 seconds
    end

    it "should calculate it's start time correctly" do
      @effort.start.should eql(Time.local(2008,"jan",1 ,8,59,26))
    end
    
    it "should store the start time when saved" do
      @effort.save!
      @effort.reload
      @effort.attributes["start"].should eql(Time.local(2008,"jan",1 ,8,59,26))  # Getting from db
    end

  end

  describe "when insufficient time references are provided" do

    it "should validate correctly if only start is provided" do
      lambda { new_effort(:contract => Factory(:rate_contract),
                        :user => Factory(:user),
                        :billed_on => nil,
                        :ticket_reference => "some ticket",
                        :name => "Effort Name",
                        :hourly_point_value => nil,
                        :start => Time.local(2008,"jan",1 ,10,15,0), 
                        :stop => nil, 
                        :duration => nil,
                        :finished => "true") }.should raise_error(RuntimeError, "you must provide at least 2 time references (start, stop or duration)")
    end

    it "should validate correctly if only stop is provided" do
      lambda { new_effort(:contract => Factory(:rate_contract),
                        :user => Factory(:user),
                        :billed_on => nil,
                        :ticket_reference => "some ticket",
                        :name => "Effort Name",
                        :hourly_point_value => nil,
                        :stop => Time.local(2008,"jan",1 ,10,15,0), 
                        :start => nil, 
                        :duration => nil,
                        :finished => "true") }.should raise_error(RuntimeError, "you must provide at least 2 time references (start, stop or duration)")
    end

    it "should validate correctly if only duration is provided" do
      lambda { new_effort(:contract => Factory(:rate_contract),
                        :user => Factory(:user),
                        :billed_on => nil,
                        :ticket_reference => "some ticket",
                        :name => "Effort Name",
                        :hourly_point_value => nil,
                        :start => nil, 
                        :stop => nil, 
                        :duration => 2341,
                        :finished => "true") }.should raise_error(RuntimeError, "you must provide at least 2 time references (start, stop or duration)")
    end

    it "should validate correctly if no time references are provided" do
      lambda { new_effort(:contract => Factory(:rate_contract),
                        :user => Factory(:user),
                        :billed_on => nil,
                        :ticket_reference => "some ticket",
                        :name => "Effort Name",
                        :hourly_point_value => nil,
                        :start => nil, 
                        :stop => nil, 
                        :duration => nil,
                        :finished => "true") }.should raise_error(RuntimeError, "you must provide at least 2 time references (start, stop or duration)")
    end

  end
  
  describe "when all 3 time references are provided" do
    it "should raise an error if duration doesn't match start and stop" do
      lambda { new_effort(:start => Time.local(2008,"jan",1 ,10,15,0), 
                                        :stop => Time.local(2008,"jan",1 ,10,30,0), 
                                        :duration => 899) }.should raise_error(RuntimeError, "The supplied duration does not match start/stop values!")
    end
    
    it "should allow instantiation if duration matches start and stop" do
      lambda { new_effort(:start => Time.local(2008,"jan",1 ,10,15,0), 
                                        :stop => Time.local(2008,"jan",1 ,10,30,0), 
                                        :duration => 900) }.should_not raise_error(RuntimeError, "The supplied duration does not match start/stop values!")
    end
  end

end

describe Effort, "private methods that identify various forms of conflict:" do
  before(:each) do
    @user = Factory(:user)
    @short_effort = create_effort(:contract => Factory(:rate_contract),
                                   :user => @user,
                                   :ticket_reference => "some ticket",
                                   :name => "Effort Name",
                                   :start => Time.local(2008,"jan",1 ,9,0,0), 
                                   :stop => Time.local(2008,"jan",1,10,0,0),
                                   :finished => true  )
    @adjacent_effort_left = create_effort(:contract => Factory(:rate_contract),
                                           :user => @user,
                                           :ticket_reference => "some ticket",
                                           :name => "Effort Name",
                                           :start => Time.local(2008,"jan",1 ,12,0,0), 
                                           :stop => Time.local(2008,"jan",1,14,0,0),
                                           :finished => true )
    @adjacent_effort_right = create_effort(:contract => Factory(:rate_contract),
                                            :user => @user,
                                            :ticket_reference => "some ticket",
                                            :name => "Effort Name",
                                            :start => Time.local(2008,"jan",1 ,14,0,0), 
                                            :stop => Time.local(2008,"jan",1,15,0,0),
                                            :finished => true )
    @slightly_seperated_effort = create_effort(:contract => Factory(:rate_contract),
                                                :user => @user,
                                                :ticket_reference => "some ticket",
                                                :name => "Effort Name",
                                                :start => Time.local(2008,"jan",1 ,15,30,0), 
                                                :stop => Time.local(2008,"jan",1,16,30,0),
                                                :finished => true )
  end
  
  describe "a effort overlapping another completely" do
    it "should identify the overlapped effort to delete" do
      @effort = new_effort(:contract => Factory(:rate_contract),
                                            :user => @user,
                                            :ticket_reference => "some ticket",
                                            :name => "Effort Name",
                                            :start => Time.local(2008,"jan",1 ,8,30,0), 
                                            :stop => Time.local(2008,"jan",1,10,30,0),
                                            :duration => nil )

      lower_array = Effort.send(:efforts_to_lower_stop_for, @effort)
      raise_array = Effort.send(:efforts_to_raise_start_for, @effort)
      split_array = Effort.send(:efforts_to_split, @effort)
      delete_array = Effort.send(:efforts_to_delete, @effort)

      lower_array.size.should eql(0)
      raise_array.size.should eql(0)
      split_array.size.should eql(0)
      delete_array.size.should eql(1)
      delete_array.should include(@short_effort)
    end
  end
  
  describe "a effort overlapping 2 adjacent efforts in part" do
    it "should identify the efforts to raise the start and lower the stop of" do
      @effort = new_effort(:contract => Factory(:rate_contract),
                                            :user => @user,
                                            :ticket_reference => "some ticket",
                                            :name => "Effort Name",
                                            :start => Time.local(2008,"jan",1 ,13,30,0), 
                                            :stop => Time.local(2008,"jan",1,14,30,0),
                                            :duration => nil )

      lower_array = Effort.send(:efforts_to_lower_stop_for, @effort)  # 1
      raise_array = Effort.send(:efforts_to_raise_start_for, @effort)  # 2
      split_array = Effort.send(:efforts_to_split, @effort)  # 3
      delete_array = Effort.send(:efforts_to_delete, @effort)  # 4

      lower_array.size.should eql(1)  # 1
      lower_array.should include(@adjacent_effort_left)
      raise_array.size.should eql(1)  # 2
      raise_array.should include(@adjacent_effort_right)
      split_array.size.should eql(0)  # 3
      delete_array.size.should eql(0)  # 4
    end
  end
  
  describe "a effort overlapping 2 non-adjacent efforts in part" do
    it "should identify the efforts to raise the start and lower the stop of" do
      @effort = new_effort(:contract => Factory(:rate_contract),
                                            :user => @user,
                                            :ticket_reference => "some ticket",
                                            :name => "Effort Name",
                                            :start => Time.local(2008,"jan",1 ,14,30,0), 
                                            :stop => Time.local(2008,"jan",1,16,0,0),
                                            :duration => nil )

      lower_array = Effort.send(:efforts_to_lower_stop_for, @effort)  # 1
      raise_array = Effort.send(:efforts_to_raise_start_for, @effort)  # 2
      split_array = Effort.send(:efforts_to_split, @effort)  # 3
      delete_array = Effort.send(:efforts_to_delete, @effort)  # 4

      lower_array.size.should eql(1)  # 1
      lower_array.should include(@adjacent_effort_right)
      raise_array.size.should eql(1)  # 2
      raise_array.should include(@slightly_seperated_effort)
      split_array.size.should eql(0)  # 3
      delete_array.size.should eql(0)  # 4
    end
  end
  
  describe "a effort that falls entirely within an existing effort's timeframe" do
    it "should identify the existing twask to split in two" do
      @effort = new_effort(:contract => Factory(:rate_contract),
                                            :user => @user,
                                            :ticket_reference => "some ticket",
                                            :name => "Effort Name",
                                            :start => Time.local(2008,"jan",1 ,12,30,0), 
                                            :stop => Time.local(2008,"jan",1,13,30,0),
                                            :duration => nil )

      lower_array = Effort.send(:efforts_to_lower_stop_for, @effort)  # 1
      raise_array = Effort.send(:efforts_to_raise_start_for, @effort)  # 2
      split_array = Effort.send(:efforts_to_split, @effort)  # 3
      delete_array = Effort.send(:efforts_to_delete, @effort)  # 4

      lower_array.size.should eql(0)  # 1
      raise_array.size.should eql(0)  # 2
      split_array.size.should eql(1)  # 3
      split_array.should include(@adjacent_effort_left)
      delete_array.size.should eql(0)  # 4
    end
  end
  
  describe "a effort overlappping only the start of another effort" do
    it "should identify the the effort to raise the start of" do
      @effort = new_effort(:contract => Factory(:rate_contract),
                                            :user => @user,
                                            :ticket_reference => "some ticket",
                                            :name => "Effort Name",
                                            :start => Time.local(2008,"jan",1 ,15,15,0), 
                                            :stop => Time.local(2008,"jan",1,16,0,0),
                                            :duration => nil )

      lower_array = Effort.send(:efforts_to_lower_stop_for, @effort)  # 1
      raise_array = Effort.send(:efforts_to_raise_start_for, @effort)  # 2
      split_array = Effort.send(:efforts_to_split, @effort)  # 3
      delete_array = Effort.send(:efforts_to_delete, @effort)  # 4

      lower_array.size.should eql(0)  # 1
      raise_array.size.should eql(1)  # 2
      raise_array.should include(@slightly_seperated_effort)
      split_array.size.should eql(0)  # 3
      delete_array.size.should eql(0)  # 4
    end
  end
  
  describe "a effort overlapping only the end of another effort" do
    it "should identify the effort to lower the stop of" do
      @effort = new_effort(:contract => Factory(:rate_contract),
                                            :user => @user,
                                            :ticket_reference => "some ticket",
                                            :name => "Effort Name",
                                            :start => Time.local(2008,"jan",1 ,16,0,0), 
                                            :stop => Time.local(2008,"jan",1,17,0,0),
                                            :duration => nil )

      lower_array = Effort.send(:efforts_to_lower_stop_for, @effort)  # 1
      raise_array = Effort.send(:efforts_to_raise_start_for, @effort)  # 2
      split_array = Effort.send(:efforts_to_split, @effort)  # 3
      delete_array = Effort.send(:efforts_to_delete, @effort)  # 4

      lower_array.size.should eql(1)  # 1
      lower_array.should include(@slightly_seperated_effort)
      raise_array.size.should eql(0)  # 2
      split_array.size.should eql(0)  # 3
      delete_array.size.should eql(0)  # 4
    end
  end
  
  describe "a effort overlapping 2 non-adjacent efforts in part, as well as another effort between them in full " do
    it "should identify a effort to delete, as well as one to raise start of, and one to lower stop of" do
      @effort = new_effort(:contract => Factory(:rate_contract),
                                            :user => @user,
                                            :ticket_reference => "some ticket",
                                            :name => "Effort Name",
                                            :start => Time.local(2008,"jan",1 ,13,0,0), 
                                            :stop => Time.local(2008,"jan",1,16,0,0),
                                            :duration => nil )

      lower_array = Effort.send(:efforts_to_lower_stop_for, @effort)  # 1
      raise_array = Effort.send(:efforts_to_raise_start_for, @effort)  # 2
      split_array = Effort.send(:efforts_to_split, @effort)  # 3
      delete_array = Effort.send(:efforts_to_delete, @effort)  # 4

      lower_array.size.should eql(1)  # 1
      lower_array.should include(@adjacent_effort_left)
      raise_array.size.should eql(1)  # 2
      raise_array.should include(@slightly_seperated_effort)
      split_array.size.should eql(0)  # 3
      delete_array.size.should eql(1)  # 4
      delete_array.should include(@adjacent_effort_right)
    end
  end

end

describe "private methods that implement conflict resolution" do
  before(:each) do
    @user = Factory(:user)
    @existing_effort = create_effort(:contract => Factory(:rate_contract),
                                  :user => @user,
                                  :ticket_reference => "some ticket",
                                  :name => "Effort Name",
                                  :start => Time.local(2008,"jan",1 ,12,0,0), 
                                  :stop => Time.local(2008,"jan",1,14,0,0),
                                  :finished => true )
  end
  
  describe "raise start" do
    it "should delete the existing effort, and create a replacement effort with the start time raised correctly" do
      @new_effort = new_effort(:contract => Factory(:rate_contract),
                           :user => @user,
                           :ticket_reference => "some ticket",
                           :name => "Effort Name",
                           :start => Time.local(2008,"jan",1 ,10,0,0),
                           :stop => Time.local(2008,"jan",1,13,0,0),
                           :duration => nil )
                           
      return_array = Effort.send(:raise_start, [@existing_effort], @new_effort)
      return_array[:deleted].should eql([@existing_effort])
      return_array[:created].size.should eql(1)
      return_array[:created][0].attributes.except("id", "duration", "created_at", "updated_at", "start").each_key do |key|
        return_array[:created][0][key].should eql(@existing_effort[key])  # attribute hashes are not guaranteed in the smae order
      end
      return_array[:created][0].start.should eql(@new_effort.stop)
      lambda { Effort.find(@existing_effort.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  describe "lower stop" do
    it "should delete the existing effort, and create a replacement effort with the stop time lowered correctly" do
      @new_effort = new_effort(:contract => Factory(:rate_contract),
                           :user => @user,
                           :ticket_reference => "some ticket",
                           :name => "Effort Name",
                           :start => Time.local(2008,"jan",1 ,13,0,0),
                           :stop => Time.local(2008,"jan",1,16,0,0),
                           :duration => nil )
                           
      return_array = Effort.send(:lower_stop, [@existing_effort], @new_effort)
      return_array[:deleted].should eql([@existing_effort])
      return_array[:created].size.should eql(1)
      return_array[:created][0].attributes.except("id", "duration", "created_at", "updated_at", "stop").each_key do |key|
        return_array[:created][0][key].should eql(@existing_effort[key])  # attribute hashes are not guaranteed in the smae order
      end
      return_array[:created][0].stop.should eql(@new_effort.start)
      lambda { Effort.find(@existing_effort.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  describe "split" do
    it "should delete the existing effort, and create 2 replacement efforts with the start and stop times adjusted correctly" do
      @new_effort = new_effort(:contract => Factory(:rate_contract),
                           :user => @user,
                           :ticket_reference => "some ticket",
                           :name => "Effort Name",
                           :start => Time.local(2008,"jan",1 ,12,30,0),
                           :stop => Time.local(2008,"jan",1,13,30,0),
                           :duration => nil )
                           
      return_array = Effort.send(:split_efforts, [@existing_effort], @new_effort)
      return_array[:deleted].should eql([@existing_effort])
      return_array[:created].size.should eql(2)
      
      return_array[:created][0].attributes.except("id", "duration", "created_at", "updated_at", "stop").each_key do |key|
        return_array[:created][0][key].should eql(@existing_effort[key])  # attribute hashes are not guaranteed in the smae order
      end
      return_array[:created][0].stop.should eql(@new_effort.start)
      
      return_array[:created][1].attributes.except("id", "duration", "created_at", "updated_at", "start").each_key do |key|
        return_array[:created][1][key].should eql(@existing_effort[key])  # attribute hashes are not guaranteed in the smae order
      end
      return_array[:created][1].start.should eql(@new_effort.stop)
      
      lambda { Effort.find(@existing_effort.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  describe "delete" do
    it "should simply delete the existing effort" do
      @new_effort = new_effort(:contract => Factory(:rate_contract),
                           :user => @user,
                           :ticket_reference => "some ticket",
                           :name => "Effort Name",
                           :start => Time.local(2008,"jan",1 ,13,0,0),
                           :stop => Time.local(2008,"jan",1,16,0,0),
                           :duration => nil )
                           
      return_array = Effort.send(:delete_efforts, [@existing_effort], @new_effort)
      return_array[:deleted].should eql([@existing_effort])
      return_array[:created].size.should eql(0)
      lambda { Effort.find(@existing_effort.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

describe Effort, "conflict handling" do
  before(:each) do
    @user = Factory(:user)
    @existing_effort = create_effort(:contract => Factory(:rate_contract),
                                  :user => @user,
                                  :billed_on => nil,
                                  :ticket_reference => "some ticket",
                                  :name => "Effort Name",
                                  :hourly_point_value => nil,
                                  :start => Time.local(2008,"jan",1 ,10,15,0), 
                                  :stop => Time.local(2008,"jan",1,15,45,0), 
                                  :duration => nil,
                                  :finished => true )
  end

  it "should correctly assign efforts if new effort overlaps at end of existing effort" do
    @new_effort = new_effort(:contract => Factory(:rate_contract),
                         :user => @user,
                         :start => Time.local(2008,"jan",1 ,15,15,0),
                         :stop => Time.local(2008,"jan",1 ,16,30,0),
                         :duration => nil,
                         :billed_on => nil,
                         :ticket_reference => "some ticket",
                         :name => "Another Effort Name",
                         :hourly_point_value => nil)
                       
    effort_changes = Effort.create_with_conflict_resolution(@new_effort)
    effort_changes[:created].size.should eql(1)
    effort_changes[:created][0].start.should eql(@existing_effort.start)  # Start time unchanged
    effort_changes[:created][0].stop.should eql(Time.local(2008,"jan",1 ,15,15,0))  # Stop time should be start of new effort
    effort_changes[:created][0].duration.should eql(@existing_effort.duration - 30.minutes)  #  New duration
  end

  it "should correctly assign efforts if overlapped at beginning of existing effort" do
    @new_effort = new_effort(:contract => Factory(:rate_contract),
                         :user => @user,
                         :start => Time.local(2008,"jan",1 ,9,00,0),
                         :stop => Time.local(2008,"jan",1 ,10,30,0),
                         :duration => nil,
                         :billed_on => nil,
                         :ticket_reference => "some ticket",
                         :name => "Another Effort Name",
                         :hourly_point_value => nil)
                       
    effort_changes = Effort.create_with_conflict_resolution(@new_effort)
    effort_changes[:created].size.should eql(1)
    effort_changes[:created][0].start.should eql(Time.local(2008,"jan",1 ,10,30,0)) # Start time shoudl be stop time of new effort
    effort_changes[:created][0].stop.should eql(@existing_effort.stop)  # Stop time unchanged 
    effort_changes[:created][0].duration.should eql(@existing_effort.duration - 15.minutes)  # New duration
  end

  it "should correctly assign efforts if new effort falls inside an existing one" do
    @new_effort = new_effort(:contract => Factory(:rate_contract),
                         :user => @user,
                         :start => Time.local(2008,"jan",1 ,12,00,0),
                         :stop => Time.local(2008,"jan",1 ,13,00,0),
                         :duration => nil,
                         :billed_on => nil,
                         :ticket_reference => "some ticket",
                         :name => "Another Effort Name",
                         :hourly_point_value => nil)
                       
    effort_changes = Effort.create_with_conflict_resolution(@new_effort)
    effort_changes[:created].size.should eql(2)  # Should split existing effort into 2.
    effort_changes[:created][0].start.should eql(@existing_effort.start)  # earlier effort start time unchanged.
    effort_changes[:created][0].stop.should eql(Time.local(2008,"jan",1 ,12,00,0))  # earlier effort stop time should be start time of new effort
    effort_changes[:created][0].duration.should eql(105.minutes.to_i)  # new duration
    
    effort_changes[:created][1].start.should eql(Time.local(2008,"jan",1 ,13,00,0))  # Later effort start time == new effort stop time.
    effort_changes[:created][1].stop.should eql(@existing_effort.stop) # Later effort stop time unchanged.
    effort_changes[:created][1].duration.should eql((2.hours + 45.minutes).to_i)  # New duration.
  end
   
  it "should not split existing effort if new effort doesn't overlap" do
    @new_effort = new_effort(:contract => Factory(:rate_contract),
                         :user => @user,
                         :start => Time.local(2008,"jan",1 ,9,00,0),
                         :stop => Time.local(2008,"jan",1 ,10,00,0),
                         :duration => nil,
                         :billed_on => nil,
                         :ticket_reference => "some ticket",
                         :name => "Another Effort Name",
                         :hourly_point_value => nil)
    
    effort_changes = Effort.create_with_conflict_resolution(@new_effort)
    effort_changes[:created].size.should eql(0)
    effort_changes[:deleted].size.should eql(0)
    effort_changes[:requested].size.should eql(1)
    effort_changes[:requested][0].should eql(@new_effort)
  end
  
  it "should replace an existing effort if the times are the same" do
    @new_effort = new_effort(:contract => Factory(:rate_contract),
                             :user => @user,
                             :billed_on => nil,
                             :ticket_reference => "some ticket",
                             :name => "Effort Name",
                             :hourly_point_value => nil,
                             :start => Time.local(2008,"jan",1 ,10,15,0), 
                             :stop => Time.local(2008,"jan",1,15,45,0), 
                             :duration => nil )
    effort_changes = Effort.create_with_conflict_resolution(@new_effort)
    effort_changes[:created].size.should eql(0)
    effort_changes[:deleted].size.should eql(1)
    effort_changes[:deleted].should include(@existing_effort)
    effort_changes[:requested].size.should eql(1)
    effort_changes[:requested][0].should eql(@new_effort)
  end
  
  it "should lower the stop time of an existing effort 
      if new effort ends at same time with relevant overlap" do
    @new_effort = new_effort(:contract => Factory(:rate_contract),
                             :user => @user,
                             :billed_on => nil,
                             :ticket_reference => "some ticket",
                             :name => "Effort Name",
                             :hourly_point_value => nil,
                             :start => Time.local(2008,"jan",1 ,14,15,0), 
                             :stop => Time.local(2008,"jan",1,15,45,0), 
                             :duration => nil )
    effort_changes = Effort.create_with_conflict_resolution(@new_effort)
    effort_changes[:created].size.should eql(1)
    effort_changes[:deleted].size.should eql(1)
    effort_changes[:created][0].start.should eql(@existing_effort.start)  # Start time unchanged
    effort_changes[:created][0].stop.should eql(Time.local(2008,"jan",1 ,14,15,0))  # Stop time should be start of new effort
    effort_changes[:created][0].duration.should eql(4.hours.to_i)  #  New duration
    effort_changes[:requested][0].should eql(@new_effort)
  end
  
  it "should raise start time of an existing effort if a 
      new effort starts at the same time with relevant overlap" do
    @new_effort = new_effort(:contract => Factory(:rate_contract),
                             :user => @user,
                             :billed_on => nil,
                             :ticket_reference => "some ticket",
                             :name => "Effort Name",
                             :hourly_point_value => nil,
                             :start => Time.local(2008,"jan",1 ,10,15,0), 
                             :stop => Time.local(2008,"jan",1,12,45,0),
                             :duration => nil )
    effort_changes = Effort.create_with_conflict_resolution(@new_effort)
    effort_changes[:created].size.should eql(1)
    effort_changes[:deleted].size.should eql(1)
    effort_changes[:created][0].start.should eql(Time.local(2008,"jan",1 ,12,45,0)) # Start time shoudl be stop time of new effort
    effort_changes[:created][0].stop.should eql(@existing_effort.stop)  # Stop time unchanged 
    effort_changes[:created][0].duration.should eql(3.hours.to_i)  # New duration
  end
end


describe Effort, "point assignment" do
    before(:each) do
      @user = Factory(:user, :point_value => 2)
    end
    
    it "should run off the user's point value by default" do
      @effort = new_effort(:contract => Factory(:rate_contract),
                       :user => @user,
                       :start => Time.local(2008,"jan",1 ,10,15,0),
                       :stop => Time.local(2008,"jan",1 ,10,30,0),
                       :duration => 15.minutes.to_i,
                       :billed_on => nil,
                       :ticket_reference => "some ticket",
                       :name => "Effort Name",
                       :hourly_point_value => nil)
      @effort.hourly_point_value.should eql(@user.point_value)
    end
    
    it "should allow explicit assignment of point value" do
      @effort = new_effort(:user => @user, :hourly_point_value => 3)
      @effort.hourly_point_value.should eql(3)
    end
    
  end


describe Effort, "when updated" do
  before(:each) do
    @effort = create_effort(:contract => Factory(:rate_contract),
                         :user => Factory(:user),
                         :start => Time.local(2008,"jan",1 ,10,15,0),
                         :stop => Time.local(2008,"jan",1 ,10,30,0),
                         :duration => 15.minutes.to_i,
                         :ticket_reference => "some ticket",
                         :name => "Effort Name")
  end
  
  it "should allow assignment of unassigned properties" do
    lambda { @effort.billed_on = "2008-01-01 10:16:00" }.should_not raise_error
  end
end


describe Effort, "validations" do
  it "should not allow start time to be greater than stop time" do
    lambda { @effort = new_effort(:contract => Factory(:rate_contract),
                              :user => Factory(:user),
                              :start => Time.local(2008,"jan",1 ,15,00,0),
                              :stop => Time.local(2008,"jan",1 ,13,00,0),
                              :duration => nil,
                              :billed_on => nil,
                              :ticket_reference => "some ticket",
                              :name => "Another Effort Name",
                              :hourly_point_value => nil) }.should raise_error(RuntimeError, 
                                                                   "Start time cannot be greater than stop time")
  end
  
  it "should not allow start time to be equal to stop time" do
    lambda { @effort = new_effort(:contract => Factory(:rate_contract),
                              :user => Factory(:user),
                              :start => Time.local(2008,"jan",1 ,15,00,0),
                              :stop => Time.local(2008,"jan",1 ,15,00,0),
                              :duration => nil,
                              :billed_on => nil,
                              :ticket_reference => "some ticket",
                              :name => "Another Effort Name",
                              :hourly_point_value => nil) }.should raise_error(RuntimeError, 
                                                                   "Start and stop times cannot be equal")
  end
end

describe Effort, "time logged accross midnight" do
  it "should split requested task at midnight into 2 seperate tasks on seperate days." do
    @new_effort = new_effort(:contract => Factory(:rate_contract),
                             :user => Factory(:user),
                             :start => Time.local(2008,"jan",1 ,23,00,0),
                             :stop => Time.local(2008,"jan",2 ,1,00,0),
                             :duration => nil,
                             :billed_on => nil,
                             :ticket_reference => "some ticket",
                             :name => "Another Effort Name",
                             :hourly_point_value => nil)
    
    effort_changes = Effort.create_with_conflict_resolution(@new_effort)
    effort_changes[:created].size.should eql(0)
    effort_changes[:deleted].size.should eql(0)
    effort_changes[:requested].size.should eql(2)
    effort_changes[:requested].should_not include(@new_effort)
    effort_changes[:requested][0].start.should eql(@new_effort.start)
    effort_changes[:requested][0].stop.should eql(Time.local(2008,"jan",2 ,0,00,0))
    effort_changes[:requested][1].start.should eql(Time.local(2008,"jan",2 ,0,00,0))
    effort_changes[:requested][1].stop.should eql(@new_effort.stop)
  end
end

describe Effort, "when timed" do
  
  describe "when created" do
    it "should allow instantiation of an effort with only a start as time reference." do
      lambda {effort = new_effort(:start => Time.local(2008,"jan",14,10,15,0), 
                                  :finished => false, :duration => nil, 
                                  :stop => nil) }.should_not raise_error
    end
    
    it "should raise error if stop is provided." do
      lambda {effort = new_effort(:start => Time.local(2008,"jan",14,10,15,0), 
                                  :finished => false, :duration => nil, 
                                  :stop => Time.local(2008,"jan",14,10,25,0)) }.should raise_error(RuntimeError, 
                                                              "Cannot provide stop or duration for an unfinished effort.")
    end
    
    it "should raise error if duration is provided." do
      lambda {effort = new_effort(:start => Time.local(2008,"jan",14,10,15,0), 
                                  :finished => false, :duration => 1200, 
                                  :stop => nil) }.should raise_error(RuntimeError, 
                                                              "Cannot provide stop or duration for an unfinished effort.")
    end
    
    it "should not allow instantiation if a user already has an unfinished effort in progress." do
      user = Factory(:user)
      create_effort(:user => user, :finished => false, :duration => nil, :stop => nil)
      lambda {effort = new_effort(:user => user,
                                  :start => Time.local(2008,"jan",14,10,15,0), 
                                  :finished => false, :duration => nil, 
                                  :stop => nil) }.should raise_error(RuntimeError, 
                                                              "User cannot have more than one unfinished effort at a time.")
    end
    
    it "should allow instantiation of an unfinished effort with finished ones under the belt" do
      user = Factory(:user)
      create_effort(:user => user, :finished => true, :duration => nil)
      lambda {effort = new_effort(:user => user,
                                  :start => Time.local(2008,"jan",14,10,15,0), 
                                  :finished => false, :duration => nil, 
                                  :stop => nil) }.should_not raise_error
    end
    
    it "should present it's duration thus far." do
      effort = create_effort(:finished => false, :duration => nil, :stop => nil, :start => (Time.now - 1.hour - 15.minutes))
      effort.duration.round.should eql((1.hour + 15.minutes).to_i)
    end
    
    it "should be finishable" do
      time = Time.now
      effort = create_effort(:finished => false, :duration => nil, :stop => nil, :start => (time - 1.hour - 15.minutes))
      effort.finish(time)
      effort.stop.should eql(time)
      effort.duration.round.should eql((1.hour + 15.minutes).to_i)
    end
  end
    
  describe "when finished" do
    it "should resolve conflicts" do
      # Testing less deep than conflict resolution on standard effort allocation, 
      # since it is performed by calls to the same methods.
      user = Factory(:user)

      existing_effort = create_effort(:contract => Factory(:rate_contract),
                                  :user => user,
                                  :name => "Effort Name",
                                  :start => Time.local(2008,"jan",1 ,12,0,0), 
                                  :stop => Time.local(2008,"jan",1,17,0,0),
                                  :finished => true )

      user.start_effort(:contract => Factory(:rate_contract),
                        :user => user,
                        :start => Time.local(2008,"jan",1 ,13,00,0),
                        :stop => nil,
                        :name => "Another Effort Name",
                        :finished => false)


      effort_changes = user.finish_effort(Time.local(2008,"jan",1,14,0,0))  # Finish at 14:00

      effort_changes[:created].size.should eql(2)  # Should split existing effort into 2.
      effort_changes[:created][0].start.should eql(existing_effort.start)  # earlier effort start time unchanged.
      effort_changes[:created][0].stop.should eql(Time.local(2008,"jan",1 ,13,00,0))  # earlier effort stop time should be start time of new effort
      effort_changes[:created][0].duration.should eql(1.hour.to_i)  # new duration

      effort_changes[:created][1].start.should eql(Time.local(2008,"jan",1 ,14,00,0))  # Later effort start time == new effort stop time.
      effort_changes[:created][1].stop.should eql(existing_effort.stop) # Later effort stop time unchanged.
      effort_changes[:created][1].duration.should eql(3.hours.to_i)  # New duration.


    end

    it "should split accross midnight where appropriate" do
      user = Factory(:user)
      
      started_effort = user.start_effort(:contract => Factory(:rate_contract),
                                         :user => user,
                                         :start => Time.local(2008,"jan",1 ,18,00,0),
                                         :stop => nil,
                                         :name => "Another Effort Name",
                                         :finished => false)
                      
      effort_changes = user.finish_effort(Time.local(2008,"jan",2, 9,0,0))  # Finish at 09:00 the next morning
      
      effort_changes[:created].size.should eql(0)
      effort_changes[:deleted].size.should eql(0)
      
      effort_changes[:requested].size.should eql(2)
      effort_changes[:requested].should_not include(started_effort)
      
      effort_changes[:requested][0].start.should eql(started_effort.start)
      effort_changes[:requested][0].stop.should eql(Time.local(2008,"jan",2 ,0,00,0))
      effort_changes[:requested][1].start.should eql(Time.local(2008,"jan",2 ,0,00,0))
      effort_changes[:requested][1].stop.should eql(Time.local(2008,"jan",2, 9,0,0))
      lambda { Effort.find(started_effort.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end

  end
  
end




# ------------------------------------------------------------------------------
def new_effort(options = {})
  options.symbolize_keys!
  effort = Effort.new({ :contract => Factory(:rate_contract),
                        :user => Factory(:user),
                        :start => Time.local(2008,"jan",1 ,10,15,0),
                        :stop => Time.local(2008,"jan",1 ,10,30,0),
                        :duration => nil,
                        :billed_on => nil,
                        :ticket_reference => "some ticket",
                        :name => "Effort Name",
                        :hourly_point_value => nil,
                        :finished => true }.merge(options) )
  effort
end

def create_effort(options = {})
  options.symbolize_keys!
  effort = Effort.create!({ :contract => Factory(:rate_contract),
                            :user => Factory(:user),
                            :start => Time.local(2008,"jan",1 ,10,15,0),
                            :stop => Time.local(2008,"jan",1 ,10,30,0),
                            :duration => nil,
                            :billed_on => nil,
                            :ticket_reference => "some ticket",
                            :name => "Effort Name",
                            :hourly_point_value => nil,
                            :finished => true }.merge(options) )
  effort
end