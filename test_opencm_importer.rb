#!/usr/bin/env ruby

# Test script for OpenChargeMap importer
# This is FREE and doesn't require an API key!

require_relative 'config/environment'

puts "Testing OpenChargeMap importer..."
puts "=" * 50
puts "✅ No API key required - this is FREE!"
puts

# Test the importer class
begin
  puts "🧪 Testing single province import (Ontario)..."
  count = ChargingStationImporter.import_province('ON')
  puts "✅ Successfully imported #{count} stations for Ontario"

  puts "\n🧪 Testing single province import (British Columbia)..."
  count = ChargingStationImporter.import_province('BC')
  puts "✅ Successfully imported #{count} stations for British Columbia"

rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end

puts "\n" + "=" * 50
puts "Test completed!"
puts "\n💡 To import all of Canada, run:"
puts "   rails charging_stations:import_canada"
puts "\n💡 To import a specific province, run:"
puts "   rails charging_stations:import_province[ON]  # Ontario"
puts "   rails charging_stations:import_province[BC]  # British Columbia"
puts "   rails charging_stations:import_province[QC]  # Quebec"
