# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

require 'spec/spec_factory'

include AuthenticatedTestHelper

# Include my matchers.
dir = File.dirname(__FILE__)
Dir[File.expand_path("#{dir}/matchers/*.rb")].uniq.each do |file|
  require file
end

# Add this to users for testing.
User.class_eval do
  def gimme_the_right(controller, action)
    role = Factory(:role)
    right = Factory(:right, :controller => controller.to_s, :action => action.to_s)
    role.rights = [right]
    self.roles << [role]
  end
end

def check_date_selection(time={})
  time.symbolize_keys
  now = Time.now
  Time.stub!(:now).and_return now
  
  day = time[:day] || now.day
  month = time[:month] || now.month
  year = time[:year] || now.year
  
  assigns[:day].should eql(day.to_i)
  assigns[:month].should eql(month.to_i)
  assigns[:year].should eql(year.to_i)
  
  assigns[:selected_date].should eql(Time.local(year, month, day))
end

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
  
end
