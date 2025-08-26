#!/usr/bin/env ruby

# Test different OpenChargeMap API endpoints
require 'httparty'

puts "Testing OpenChargeMap API endpoints..."
puts "=" * 50

# Test different base URLs and endpoints
test_urls = [
  "https://api.openchargemap.io/v3/poi?countrycode=CA&regioncode=ON&maxresults=10",
  "https://api.openchargemap.io/v3/referencedata?countrycode=CA&regioncode=ON&maxresults=10",
  "https://api.openchargemap.io/v3/core?countrycode=CA&regioncode=ON&maxresults=10",
  "https://api.openchargemap.io/v3/poi?countrycode=CA&maxresults=10",
  "https://api.openchargemap.io/v3/poi?maxresults=10"
]

test_urls.each_with_index do |url, index|
  puts "\n🧪 Test #{index + 1}: #{url}"

  begin
    response = HTTParty.get(url, {
      headers: {
        'User-Agent' => 'ChargeFinder-App/1.0 (https://chargefinder.com)',
        'Accept' => 'application/json'
      },
      timeout: 10
    })

    puts "  Status: #{response.code}"
    puts "  Headers: #{response.headers['content-type']}"

    if response.success?
      puts "  ✅ Success!"
      parsed = response.parsed_response
      puts "  Response type: #{parsed.class}"
      puts "  Response length: #{parsed.length if parsed.respond_to?(:length)}"

      if parsed.is_a?(Array) && parsed.any?
        puts "  First item keys: #{parsed.first.keys if parsed.first.respond_to?(:keys)}"
      end
    else
      puts "  ❌ Failed: #{response.message}"
      puts "  Body: #{response.body[0..200]}..." if response.body
    end

  rescue => e
    puts "  ❌ Error: #{e.message}"
  end

  sleep(2) # Rate limiting
end

puts "\n" + "=" * 50
puts "API endpoint testing completed!"
