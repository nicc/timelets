class PointContract < Contract
  validates_presence_of :point_rate, :ah_point_adjustment, :retainer_points
end