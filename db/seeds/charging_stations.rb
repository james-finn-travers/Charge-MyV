# Sample charging station data for testing
puts "Creating sample charging stations..."

# Sample stations for major Canadian cities
sample_stations = [
  {
    name: "Sample Station 1",
    address: "123 Test St, Toronto, ON",
    latitude: 43.6532,
    longitude: -79.3832,
    connector_types: "Type 2, CCS",
    power_output: 50.0,
    is_operational: true
  },
  {
    name: "Sample Station 2",
    address: "456 Example Ave, Ottawa, ON",
    latitude: 45.4215,
    longitude: -75.6972,
    connector_types: "CHAdeMO, CCS",
    power_output: 150.0,
    is_operational: true
  }
]

sample_stations.each do |station_data|
  ChargingStation.create!(station_data)
end

puts "Created #{ChargingStation.count} sample stations"
puts "You can now test your app with this sample data."
puts "To get real data, get an API key from OpenChargeMap:"
puts "https://openchargemap.io/site/develop"
