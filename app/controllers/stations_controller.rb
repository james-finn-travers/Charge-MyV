class StationsController < ApplicationController
    def index 
        @current_latitude = params[:latitude]
        @current_longitude = params[:longitude]

        @stations = ChargingStation.all.map do |station|
            distance = calculate_distance(
                @current_latitude.to_f,
                @current_longitude.to_f,
                station.latitude,
                station.longitude
            )
            [station, distance]
        end.sort_by { |_, distance| distance }
    end

    private

    def calculate_distance(lat1, lon1, lat2, lon2)
        rad_per_deg = Math::PI / 180
        rkm = 6371 # Earth radius in kilometers
        rm = rkm * 1000 # Earth radius in meters

        dlat_rad = (lat2 - lat1) * rad_per_deg
        dlon_rad = (lon2 - lon1) * rad_per_deg

        lat1_rad, lon1_rad = lat1 * rad_per_deg, lon1 * rad_per_deg
        lat2_rad, lon2_rad = lat2 * rad_per_deg, lon2 * rad_per_deg

        a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

        rm * c # Distance in meters
    end
end