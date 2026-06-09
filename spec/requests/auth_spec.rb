require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:user) { User.create!(email: "login@example.com", password: "password123") }

  describe "POST /auth/signup" do
    it "creates a new user and returns an access token" do
      post "/auth/signup", params: { user: { email: "new_user@example.com", password: "password123" } }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body["access_token"]).to be_present
      expect(body["token_type"]).to eq("bearer")
      expect(User.find_by(email: "new_user@example.com")).to be_present
    end

    it "returns an error when the user already exists" do
      existing_user = User.create!(email: "existing@example.com", password: "password123")

      post "/auth/signup", params: { user: { email: existing_user.email, password: "password123" } }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)

      expect(body["error"]).to eq("User already registered")
    end
  end

  describe "POST /auth/login" do
    it "returns an access token for valid credentials" do

      post "/auth/login", params: { user: { email: user.email, password: "password123" } }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body["access_token"]).to be_present
      expect(body["token_type"]).to eq("bearer")
    end

    it "returns an error for invalid password" do
      post "/auth/login", params: { user: { email: user.email, password: "wrongpassword" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("Invalid Password")
    end

    it "returns an error when the user does not exist" do
      post "/auth/login", params: { user: { email: "missing@example.com", password: "password123" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("User not found")
    end
  end

  describe "Unauthorized access" do
    it "returns unauthorized when no access token is provided" do
      short_url = ShortUrl.create!(url: "https://example.com", user: user)

      post "/url/#{short_url.code}/notify"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
