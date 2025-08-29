require 'net/http'
require 'json'
require 'uri'

class ManualGeocoder
  NOMINATIM_BASE_URL = "https://nominatim.openstreetmap.org/search"
  
  def self.search(address)
    uri = URI(NOMINATIM_BASE_URL)
    uri.query = URI.encode_www_form({
      q: address,
      format: 'json',
      limit: 1,
      addressdetails: 1,
      countrycodes: 'ca'  # Limit to Canada
    })
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    
    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = 'ChargeFinder/1.0'
    
    response = http.request(request)
    
    if response.code == '200'
      results = JSON.parse(response.body)
      return results.map do |result|
        OpenStruct.new(
          latitude: result['lat'].to_f,
          longitude: result['lon'].to_f,
          address: result['display_name'],
          city: result.dig('address', 'city') || result.dig('address', 'town'),
          province: result.dig('address', 'state'),
          country: result.dig('address', 'country')
        )
      end
    else
      Rails.logger.error "Geocoding failed: HTTP #{response.code}"
      return []
    end
    
  rescue => e
    Rails.logger.error "Geocoding error: #{e.message}"
    return []
  end
end
