class BillingCycle < ActiveRecord::Base
  validates_presence_of :name, :day_of_month
  validates_uniqueness_of :name
  validates_numericality_of :day_of_month
  
  has_many :customers
end
