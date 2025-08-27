# app/services/charging_station_importer.rb
class ChargingStationImporter
  include HTTParty
  base_uri 'api.openchargemap.io/v3'

  def self.import_ontario_stations
    api_key = Rails.application.credentials.dig(:open_charge_map, :api_key)
    puts "Starting import of Ontario charging stations..."
    start_time = Time.current
    
    unless api_key.present?
      puts "Error: OpenChargeMap API key not configured"
      puts "Please set it in config/credentials.yml.enc using:"
      puts "EDITOR='code --wait' bin/rails credentials:edit"
      return
    end

    page = 1
    per_page = 100
    total_imported = 0

    loop do
      print "\rFetching page #{page}... "
      
      response = get('/poi', query: {
        countrycode: 'CA',
        regioncode: 'ON',  # Specifically for Ontario
        maxresults: per_page,
        page: page,
        compact: true,
        verbose: false,
        key: api_key
      })
      
      unless response.success?
        puts "\nError: API request failed with status #{response.code}"
        return
      end

      stations = response.parsed_response
      break if stations.empty?

      stations.each do |station|
        begin
          create_or_update_station(station)
          total_imported += 1
          print "\rImported #{total_imported} stations..."
        rescue => e
          puts "\nWarning: Skipped station - #{e.message}"
        end
      end
      
      page += 1
      break if stations.length < per_page
      
      # Add a small delay to respect rate limits
      sleep(0.5)
    end

    duration = Time.current - start_time
    puts "\nImport completed!"
    puts "Total stations imported: #{total_imported}"
    puts "Time taken: #{duration.round(2)} seconds"
    total_imported
  end

  def self.import_canadian_stations
    api_key = Rails.application.credentials.dig(:open_charge_map, :api_key)
    puts "Starting import of Canadian charging stations..."
    
    unless api_key.present?
      puts "Error: OpenChargeMap API key not configured"
      return
    end

    page = 1
    per_page = 100
    total_imported = 0

    loop do
      print "\rFetching page #{page}..."
      
      response = get('/poi', query: {
        countrycode: 'CA',  # Changed to fetch all Canadian stations
        maxresults: per_page,
        page: page,
        compact: true,
        verbose: false,
        key: api_key
      })
      
      unless response.success?
        puts "\nError: API request failed with status #{response.code}"
        return
      end

      stations = response.parsed_response
      break if stations.empty?

      stations.each do |station|
        begin
          create_or_update_station(station)
          total_imported += 1
          print "."
        rescue => e
          puts "\nWarning: Skipped station - #{e.message}"
        end
      end
      
      page += 1
      break if stations.length < per_page
    end

    puts "\nImport completed! Total stations imported: #{total_imported}"
    total_imported
  end

  private

  def self.create_or_update_station(data)
    return unless data['AddressInfo'] && data['Connections']

    address_info = data['AddressInfo']
    address = [
      address_info['AddressLine1'],
      address_info['Town'],
      address_info['StateOrProvince']
    ].compact.join(', ')

    # Get connector types
    connector_types = data['Connections']
      .select { |c| c['ConnectionType'].present? && c['ConnectionType']['Title'].present? }
      .map { |c| c['ConnectionType']['Title'] }
      .uniq
      .join(',')

    # Get max power
    power_output = data['Connections']
      .map { |c| c['PowerKW'] }
      .compact
      .max

    ChargingStation.find_or_initialize_by(
      latitude: address_info['Latitude'],
      longitude: address_info['Longitude']
    ).update!(
      name: address_info['Title'],
      address: address,
      connector_types: connector_types,
      power_output: power_output,
      is_operational: data['StatusType']&.dig('IsOperational') || true
    )
  end
end

