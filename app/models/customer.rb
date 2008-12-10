class Customer < ActiveRecord::Base
  belongs_to :billing_cycle
  has_many :contracts
  
  validates_presence_of :name, :billing_cycle_id
  validates_uniqueness_of :name
end
