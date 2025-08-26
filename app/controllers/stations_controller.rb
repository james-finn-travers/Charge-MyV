class StationsController < ApplicationController
    def index
        @location = params[:location]
        @current_latitude = params[:latitude]
        @current_longitude = params[:longitude]
        @radius = params[:radius] || 10 # Default radius in km
        @charging_types = params[:charging_types] || []

        @stations = if @current_latitude.present? && @current_longitude.present?
            ChargingStation.nearby(@current_latitude, @current_longitude, @radius)
        elsif @location.present?
            ChargingStation.nearby(@location, @radius)
        else
            ChargingStation.all
        end

        # Filter by connector types if specified
        if @charging_types.present? && @charging_types.any?
            if @stations.respond_to?(:where)
                # Build safe OR conditions for connector_types
                conditions = @charging_types.map { |type| "connector_types ILIKE ?" }
                @stations = @stations.where(conditions.join(" OR "), *@charging_types.map { |type| "%#{type}%" })
            end
        end
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


    def show
        @station = ChargingStation.find(params[:id])
        @current_latitude = params[:latitude]
        @current_longitude = params[:longitude]
    end
end
