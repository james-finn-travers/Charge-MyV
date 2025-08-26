#!/usr/bin/env ruby

# Test script for ChargeFinder importer
# Run this to test the importer without importing all of Canada

require_relative 'config/environment'

puts "Testing ChargeFinder importer..."
puts "=" * 50

# Check if API key is set
if ENV['CHARGEFINDER_API_KEY'].blank?
  puts "❌ CHARGEFINDER_API_KEY not set"
  puts "Please set it with: export CHARGEFINDER_API_KEY='your_key_here'"
  exit 1
end

puts "✅ API key found"
puts "🔑 Key: #{ENV['CHARGEFINDER_API_KEY'][0..10]}..."

# Test the importer class
begin
  importer = ChargefinderImporter.new
  puts "✅ Importer class loaded successfully"

  # Test a single province (Ontario)
  puts "\n🧪 Testing single province import (Ontario)..."
  count = importer.import_province('ON')
  puts "✅ Imported #{count} stations for Ontario"

rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end

puts "\n" + "=" * 50
puts "Test completed!"
