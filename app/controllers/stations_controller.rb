class StationsController < ApplicationController
  def index
    @stations = find_nearby_stations
  end

  def show
    @station = ChargingStation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Charging station not found"
    redirect_to stations_path
  end

  private

  def find_nearby_stations
    base_query = ChargingStation.all

    # Apply power filters
    if params[:min_power].present?
      base_query = base_query.where('power_output >= ?', params[:min_power].to_f)
    end

    if params[:max_power].present?
      base_query = base_query.where('power_output <= ?', params[:max_power].to_f)
    end

    # Apply location-based filtering
    if location_params_present?
      stations_with_distance = find_stations_by_location(base_query)
      return stations_with_distance
    end

    # Default: return all stations (limited) if no location specified
    base_query.limit(50).order(:name)
  end

  def location_params_present?
    (params[:latitude].present? && params[:longitude].present?) || 
    params[:location].present?
  end

  def find_stations_by_location(base_query)
    radius = params[:radius].present? ? params[:radius].to_f : 10.0
    
    if params[:latitude].present? && params[:longitude].present?
      # Use provided coordinates (from geolocation)
      lat = params[:latitude].to_f
      lng = params[:longitude].to_f
      find_stations_near_coordinates(base_query, lat, lng, radius)
    elsif params[:location].present?
      # Geocode the address
      find_stations_near_address(base_query, params[:location], radius)
    else
      base_query.limit(50).order(:name)
    end
  end

  def find_stations_near_coordinates(base_query, lat, lng, radius)
    # Use Haversine formula to calculate distance using standard PostgreSQL
    # We need to use a subquery to filter by the calculated distance
    distance_sql = "6371 * acos(
      cos(radians(#{lat})) * 
      cos(radians(latitude)) * 
      cos(radians(longitude) - radians(#{lng})) + 
      sin(radians(#{lat})) * 
      sin(radians(latitude))
    )"
    
    stations = base_query.select(
      "*",
      Arel.sql("ROUND(CAST(#{distance_sql} AS numeric), 1) AS distance")
    ).where(Arel.sql("#{distance_sql} <= ?"), radius)
    .order(Arel.sql("ROUND(CAST(#{distance_sql} AS numeric), 1)"))
    
    stations.to_a
  end

  def find_stations_near_address(base_query, address, radius)
    # Simple hardcoded coordinates for common Canadian cities for testing
    city_coordinates = {
      'toronto' => [43.6532, -79.3832],
      'ottawa' => [45.4215, -75.6972],
      'hamilton' => [43.2557, -79.8711],
      'london' => [42.9849, -81.2453],
      'windsor' => [42.3149, -83.0364],
      'kingston' => [44.2312, -76.4860],
      'kitchener' => [43.4501, -80.4956],
      'waterloo' => [43.4643, -80.5204],
      'mississauga' => [43.5890, -79.6441],
      'brampton' => [43.7315, -79.7624],
      'markham' => [43.8561, -79.3370],
      'vaughan' => [43.8361, -79.4985],
      'richmond hill' => [43.8828, -79.4403],
      'oakville' => [43.4675, -79.6877],
      'burlington' => [43.3255, -79.7990],
      'oshawa' => [43.8971, -78.8658],
      'st. catharines' => [43.1594, -79.2469],
      'niagara falls' => [43.0896, -79.0849],
      'guelph' => [43.5448, -80.2482],
      'cambridge' => [43.3616, -80.3144],
      'brantford' => [43.1394, -80.2644],
      'barrie' => [44.3894, -79.6903],
      'sudbury' => [46.4917, -80.9930],
      'thunder bay' => [48.3809, -89.2477],
      'sault ste. marie' => [46.5197, -84.3467],
      'north bay' => [46.3091, -79.4608],
      'timmins' => [48.4758, -81.3304],
      'sarnia' => [42.9994, -82.3888],
      'peterborough' => [44.3091, -78.3197],
      'belleville' => [44.1628, -77.3832]
    }
    
    # Normalize the input address
    normalized_address = address.downcase.strip
    
    # Try to find coordinates for the city
    coordinates = nil
    city_coordinates.each do |city, coords|
      if normalized_address.include?(city)
        coordinates = coords
        break
      end
    end
    
    if coordinates
      lat, lng = coordinates
      Rails.logger.info "Found coordinates for #{address}: lat: #{lat}, lng: #{lng}"
      find_stations_near_coordinates(base_query, lat, lng, radius)
    else
      # Try manual geocoding as fallback
      begin
        Rails.logger.info "Attempting manual geocoding for: #{address}"
        results = manual_geocode(address)
        
        if results.any?
          result = results.first
          lat = result[:latitude]
          lng = result[:longitude]
          Rails.logger.info "Geocoded #{address} to lat: #{lat}, lng: #{lng}"
          find_stations_near_coordinates(base_query, lat, lng, radius)
        else
          Rails.logger.warn "No results found for: #{address}"
          flash.now[:alert] = "Location '#{address}' not found. Try: Toronto, Ottawa, Hamilton, London, etc."
          base_query.limit(50).order(:name)
        end
      rescue => e
        Rails.logger.error "Geocoding failed for #{address}: #{e.message}"
        flash.now[:alert] = "Unable to find location. Try: Toronto, Ottawa, Hamilton, London, etc."
        base_query.limit(50).order(:name)
      end
    end
  end

  def manual_geocode(address)
    require 'net/http'
    require 'json'
    
    uri = URI('https://nominatim.openstreetmap.org/search')
    uri.query = URI.encode_www_form({
      q: address,
      format: 'json',
      limit: 1,
      countrycodes: 'ca'
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
        {
          latitude: result['lat'].to_f,
          longitude: result['lon'].to_f,
          address: result['display_name']
        }
      end
    else
      Rails.logger.error "Manual geocoding failed: HTTP #{response.code}"
      return []
    end
    
  rescue => e
    Rails.logger.error "Manual geocoding error: #{e.message}"
    return []
  end
end
