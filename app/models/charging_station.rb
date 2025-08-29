class ChargingStation < ApplicationRecord
  # Explicitly set the table name to avoid conflicts with model name override
  self.table_name = "charging_stations"
  
  # Configure Rails to use 'station' for route helpers instead of 'charging_station'
  def self.model_name
    @model_name ||= ActiveModel::Name.new(self, nil, "Station")
  end
  
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

  # Status display helper
  def status
    is_operational? ? 'Operational' : 'Out of Service'
  end

  # Status CSS class helper
  def status_css_class
    is_operational? ? 'text-green-600' : 'text-red-600'
  end

  # Badge CSS class helper
  def status_badge_class
    is_operational? ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
  end

  # Google Maps integration
  def google_maps_url
    # Use coordinates for more accurate location
    "https://www.google.com/maps/search/?api=1&query=#{latitude},#{longitude}"
  end

  def google_maps_directions_url(from_lat: nil, from_lng: nil)
    base_url = "https://www.google.com/maps/dir/"
    
    if from_lat && from_lng
      # Directions from specific location
      "#{base_url}#{from_lat},#{from_lng}/#{latitude},#{longitude}"
    else
      # Directions from user's current location
      "#{base_url}/#{latitude},#{longitude}"
    end
  end

  def google_maps_search_url
    # Search by name and address for business listings
    query = "#{name} #{address}".strip
    encoded_query = CGI.escape(query)
    "https://www.google.com/maps/search/#{encoded_query}"
  end
end
