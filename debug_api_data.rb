#!/usr/bin/env ruby

# Debug script to see the actual OpenChargeMap API data structure
require_relative 'config/environment'

puts "Debugging OpenChargeMap API data structure..."
puts "=" * 60

# Get a few stations and examine their data
stations = ChargingStation.limit(3)

if stations.any?
  puts "Found #{stations.count} stations in database"

  stations.each_with_index do |station, index|
    puts "\n--- Station #{index + 1}: #{station.name} ---"
    puts "Connector Types: #{station.connector_types}"
    puts "Power Output: #{station.power_output}kW"
    puts "Address: #{station.address}"
  end
else
  puts "No stations found in database yet"
end

puts "\n" + "=" * 60
puts "Now testing API response structure..."

# Test the API directly to see the data structure
require 'httparty'

response = HTTParty.get('https://api.openchargemap.io/v3/poi', query: {
  key: '1b52d4b3-66ec-4ef9-8456-03c5dbce3d69',
  countrycode: 'CA',
  regioncode: 'ON',
  maxresults: 2
})

if response.success?
  puts "✅ API request successful"
  data = response.parsed_response

  if data.is_a?(Array) && data.any?
    puts "Found #{data.length} stations in API response"

    data.each_with_index do |station, index|
      puts "\n--- API Station #{index + 1}: #{station['AddressInfo']&.dig('Title')} ---"
      puts "Keys: #{station.keys.join(', ')}"

      if station['Connections']
        puts "Connections: #{station['Connections'].length} connection(s)"
        station['Connections'].each_with_index do |conn, conn_index|
          puts "  Connection #{conn_index + 1}:"
          puts "    Keys: #{conn.keys.join(', ')}"
          puts "    ConnectionType: #{conn['ConnectionType']}"
          puts "    PowerKW: #{conn['PowerKW']}"
        end
      else
        puts "No Connections data found"
      end
    end
  else
    puts "❌ Unexpected API response format"
  end
else
  puts "❌ API request failed: #{response.code} - #{response.message}"
end

puts "\n" + "=" * 60
puts "Debug completed!"
