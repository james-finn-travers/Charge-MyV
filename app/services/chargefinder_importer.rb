class ChargefinderImporter
  include HTTParty
  base_uri "https://api.chargefinder.com"

  # You'll need to get an API key from ChargeFinder
  # https://chargefinder.com/developers
  API_KEY = ENV["CHARGEFINDER_API_KEY"]

  def self.import_canada_stations
    new.import_all_canada
  end

  def import_all_canada
    puts "Starting import of Canadian charging stations..."

    # Import by provinces/territories for better coverage
    provinces = [
      "AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"
    ]

    total_stations = 0

    provinces.each do |province|
      puts "Importing stations for #{province}..."
      stations = import_province(province)
      total_stations += stations
      puts "Imported #{stations} stations for #{province}"

      # Rate limiting - be respectful to the API
      sleep(1)
    end

    puts "Import complete! Total stations imported: #{total_stations}"
  end

  def import_province(province_code)
    response = fetch_stations(province_code)
    return 0 unless response&.success?

    stations_count = 0
    response.parsed_response["stations"]&.each do |station_data|
      if create_or_update_station(station_data)
        stations_count += 1
      end
    end

    stations_count
  rescue => e
    puts "Error importing #{province_code}: #{e.message}"
    0
  end

  private

  def fetch_stations(province_code, page = 1)
    self.class.get("/v1/stations", {
      query: {
        country: "CA",
        region: province_code,
        page: page,
        limit: 100, # Adjust based on API limits
        api_key: API_KEY
      },
      headers: {
        "Accept" => "application/json",
        "User-Agent" => "ChargeFinder-Importer/1.0"
      }
    })
  end

  def create_or_update_station(data)
    # Find existing station by coordinates or external ID
    station = ChargingStation.find_or_initialize_by(
      external_id: data["id"] || "#{data['latitude']}_#{data['longitude']}"
    )

    # Update station attributes
    station.assign_attributes(
      name: data["name"] || "Unknown Station",
      address: build_address(data),
      latitude: data["latitude"],
      longitude: data["longitude"],
      connector_types: extract_connector_types(data["connectors"]),
      power_output: extract_max_power(data["connectors"]),
      availability: determine_availability(data),
      network: data["network"] || "Unknown",
      pricing: data["pricing"],
      operating_hours: data["hours"],
      amenities: data["amenities"]&.join(", ")
    )

    station.save!
    station
  rescue => e
    puts "Error saving station #{data['name']}: #{e.message}"
    false
  end

  def build_address(data)
    address_parts = [
      data["address"]&.dig("street"),
      data["address"]&.dig("city"),
      data["address"]&.dig("state"),
      data["address"]&.dig("postal_code")
    ].compact

    address_parts.any? ? address_parts.join(", ") : "Address not available"
  end

  def extract_connector_types(connectors)
    return "Unknown" unless connectors&.any?

    types = connectors.map do |connector|
      case connector["type"]&.downcase
      when /type.?1|j1772/i
        "Type 1"
      when /type.?2|mennekes/i
        "Type 2"
      when /ccs|combo/i
        "CCS"
      when /chademo/i
        "CHAdeMO"
      when /tesla/i
        "Tesla"
      else
        connector["type"] || "Unknown"
      end
    end

    types.uniq.join(", ")
  end

  def extract_max_power(connectors)
    return nil unless connectors&.any?

    max_power = connectors.map { |c| c["power_kw"] }.compact.max
    max_power&.to_f
  end

  def determine_availability(data)
    case data["status"]&.downcase
    when /operational|available|active/i
      "available"
    when /maintenance|offline|inactive/i
      "unavailable"
    else
      "unknown"
    end
  end
end
