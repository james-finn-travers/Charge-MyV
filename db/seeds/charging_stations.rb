# Sample charging station data for testing
puts "Creating sample charging stations..."

# Sample stations for major Canadian cities
sample_stations = [
  {
    name: "Downtown Toronto Charging Hub",
    address: "123 Queen Street West, Toronto, ON M5H 2M9",
    latitude: 43.6532,
    longitude: -79.3832,
    connector_types: "Type 2, CCS, Tesla",
    power_output: 50.0,
    availability: "available",
    network: "Tesla Supercharger"
  },
  {
    name: "Vancouver EV Station",
    address: "456 Granville Street, Vancouver, BC V6C 1T4",
    latitude: 49.2827,
    longitude: -123.1207,
    connector_types: "Type 1, Type 2, CHAdeMO",
    power_output: 25.0,
    availability: "available",
    network: "Petro-Canada"
  },
  {
    name: "Montreal Central Charging",
    address: "789 Sainte-Catherine Street, Montreal, QC H3B 1K3",
    latitude: 45.5017,
    longitude: -73.5673,
    connector_types: "Type 2, CCS",
    power_output: 22.0,
    availability: "available",
    network: "Circuit Électrique"
  },
  {
    name: "Calgary Downtown Station",
    address: "321 8th Avenue SW, Calgary, AB T2P 1J3",
    latitude: 51.0447,
    longitude: -114.0719,
    connector_types: "Type 2, CCS, Tesla",
    power_output: 75.0,
    availability: "available",
    network: "Tesla Supercharger"
  },
  {
    name: "Ottawa Parliament Charging",
    address: "111 Wellington Street, Ottawa, ON K1A 0A6",
    latitude: 45.4215,
    longitude: -75.6972,
    connector_types: "Type 2, CCS",
    power_output: 22.0,
    availability: "available",
    network: "Hydro Ottawa"
  }
]

sample_stations.each do |station_data|
  ChargingStation.find_or_create_by(
    latitude: station_data[:latitude],
    longitude: station_data[:longitude]
  ) do |station|
    station.name = station_data[:name]
    station.address = station_data[:address]
    station.connector_types = station_data[:connector_types]
    station.power_output = station_data[:power_output]
    station.availability = station_data[:availability]
    station.network = station_data[:network]
  end
end

puts "✅ Created #{sample_stations.length} sample charging stations!"
puts "You can now test your app with this sample data."
puts "To get real data, get an API key from OpenChargeMap:"
puts "https://openchargemap.io/site/develop"
