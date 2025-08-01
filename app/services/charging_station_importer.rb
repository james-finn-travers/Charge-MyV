class ChargingStationImporter
  include HTTParty
  base_uri 'api.openchargemap.io/v3'

  def self.import_ontario_stations
    response = get('/poi', query: {
      countrycode: 'CA',
      regioncode: 'ON',
      maxresults: 1000,
      compact: true,
      verbose: false
    })

    return unless response.success?

    response.parsed_response.each do |station|
      create_or_update_station(station)
    end
  end

  private

  def self.create_or_update_station(data)
    ChargingStation.find_or_initialize_by(
      latitude: data['AddressInfo']['Latitude'],
      longitude: data['AddressInfo']['Longitude']
    ).tap do |station|
      station.update!(
        name: data['AddressInfo']['Title'],
        address: [
          data['AddressInfo']['AddressLine1'],
          data['AddressInfo']['Town'],
          data['AddressInfo']['StateOrProvince']
        ].compact.join(', '),
        connector_types: extract_connector_types(data['Connections']),
        availability: data['StatusType']&.dig('IsOperational') ? 'available' : 'unavailable',
        power_output: extract_max_power(data['Connections'])
      )
    end
  end

  def self.extract_connector_types(connections)
    connections.map { |c| c['ConnectionType']['Title'] }.uniq.join(',')
  end

  def self.extract_max_power(connections)
    connections.map { |c| c['PowerKW'] }.compact.max
  end
end