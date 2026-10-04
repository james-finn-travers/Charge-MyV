require 'rails_helper'

RSpec.describe "Api::V1::Stations", type: :request do
  describe "GET /api/v1/stations" do
    it "returns a list of stations" do
      create_list(:charging_station, 3)
      get "/api/v1/stations"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to be >= 3
    end

    it "filters stations by location" do
      toronto_station = create(:charging_station, address: '100 Yonge St, Toronto, ON', latitude: 43.6532, longitude: -79.3832)
      get "/api/v1/stations", params: { location: 'Toronto', radius: 10 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).not_to be_empty
    end
  end

  describe "GET /api/v1/stations/:id" do
    it "returns single station details" do
      station = create(:charging_station)
      get "/api/v1/stations/#{station.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(station.id)
    end

    it "returns 404 for invalid station ID" do
      get "/api/v1/stations/999999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
