#!/usr/bin/env ruby

# Test script for stations queries
puts "=== Testing Stations Queries ==="

# Test 1: Basic station count
puts "\n1. Basic Station Count:"
total_stations = ChargingStation.count
puts "Total stations in database: #{total_stations}"

# Test 2: Power filtering
puts "\n2. Power Filtering Tests:"
high_power = ChargingStation.where('power_output >= ?', 50).count
puts "Stations with >= 50kW: #{high_power}"

medium_power = ChargingStation.where('power_output BETWEEN ? AND ?', 25, 100).count
puts "Stations with 25-100kW: #{medium_power}"

# Test 3: Sample stations with power data
puts "\n3. Sample Stations with Power Data:"
sample_stations = ChargingStation.where.not(power_output: nil).limit(5)
sample_stations.each do |s|
  puts "- #{s.name}: #{s.power_output}kW (#{s.address})"
end

# Test 4: Distance calculation test (Toronto coordinates)
puts "\n4. Distance Calculation Test (Toronto area):"
lat, lng, radius = 43.6532, -79.3832, 20

begin
  distance_sql = "6371 * acos(
    cos(radians(#{lat})) * 
    cos(radians(latitude)) * 
    cos(radians(longitude) - radians(#{lng})) + 
    sin(radians(#{lat})) * 
    sin(radians(latitude))
  )"
  
  nearby_stations = ChargingStation.select(
    "name, address, power_output",
    "ROUND(#{distance_sql}, 1) AS distance"
  ).where("#{distance_sql} <= ?", radius)
  .order("distance")
  .limit(5)
  
  puts "Stations within #{radius}km of Toronto:"
  nearby_stations.each do |s|
    puts "- #{s.name}: #{s.distance}km away, #{s.power_output}kW"
  end
  
  puts "\nGenerated SQL:"
  puts nearby_stations.to_sql
  
rescue => e
  puts "Error in distance calculation: #{e.message}"
end

# Test 5: Combined power and location filtering
puts "\n5. Combined Filtering Test (High power stations near Toronto):"
begin
  base_query = ChargingStation.where('power_output >= ?', 50)
  
  distance_sql = "6371 * acos(
    cos(radians(#{lat})) * 
    cos(radians(latitude)) * 
    cos(radians(longitude) - radians(#{lng})) + 
    sin(radians(#{lat})) * 
    sin(radians(latitude))
  )"
  
  filtered_stations = base_query.select(
    "name, power_output",
    "ROUND(#{distance_sql}, 1) AS distance"
  ).where("#{distance_sql} <= ?", radius)
  .order("distance")
  .limit(3)
  
  puts "High power (>=50kW) stations within #{radius}km of Toronto:"
  filtered_stations.each do |s|
    puts "- #{s.name}: #{s.power_output}kW, #{s.distance}km away"
  end
  
rescue => e
  puts "Error in combined filtering: #{e.message}"
end

puts "\n=== Query Testing Complete ==="
