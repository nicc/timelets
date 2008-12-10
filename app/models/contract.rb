class Contract < ActiveRecord::Base
  belongs_to :customer
  validates_presence_of :customer_id, :name
  validates_inclusion_of :retainer_includes_ah, :in => [true,false]
  validates_uniqueness_of :name
  has_many :efforts
end
