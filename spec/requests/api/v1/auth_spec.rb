require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: 'user@example.com', password: 'password123') }

    it "returns a JWT token on successful login" do
      post "/api/v1/auth/login", params: { email: 'user@example.com', password: 'password123' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('token')
      expect(json).to have_key('expires_at')
    end

    it "returns 401 on bad credentials" do
      post "/api/v1/auth/login", params: { email: 'user@example.com', password: 'wrongpassword' }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
