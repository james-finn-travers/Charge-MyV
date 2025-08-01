class ChargingStation < ApplicationRecord
  validates :name, presence: true
  validates :address, presence: true
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :connector_types, presence: true
  validates :power_output, numericality: { greater_than: 0 }, allow_nil: true

  # Convert connector_types string to array
  def connector_types_array
    connector_types.split(',').map(&:strip)
  end

  # Scope for finding nearby stations
  scope :nearby, ->(lat, lon, radius_km = 5) {
    where(
      "ST_Distance(
        ST_MakePoint(longitude, latitude)::geography,
        ST_MakePoint(?, ?)::geography
      ) <= ?",
      lon, lat, radius_km * 1000
    )
  }
end
