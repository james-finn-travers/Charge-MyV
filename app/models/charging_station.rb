class ChargingStation < ApplicationRecord
  geocoded_by :address
  # Only geocode when we don't already have coordinates, and the address changed
  after_validation :geocode_safely, if: ->(obj) {
    obj.address.present? && obj.address_changed? && (obj.latitude.blank? || obj.longitude.blank?)
  }

  def geocode_safely
    geocode
  rescue StandardError => e
    Rails.logger.warn("Geocoding skipped: #{e.class} - #{e.message}")
  end

  validates :name, presence: true
  validates :address, presence: true
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :power_output, numericality: { greater_than: 0 }, allow_nil: true

  # Convert connector_types string to array
  def connector_types_array
    connector_types.split(",").map(&:strip)
  end

  # Scope for finding nearby stations using PostGIS
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
