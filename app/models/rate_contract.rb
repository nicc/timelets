class RateContract < Contract
  validates_presence_of :oh_hourly_rate, :ah_hourly_rate, :retainer_hours
end