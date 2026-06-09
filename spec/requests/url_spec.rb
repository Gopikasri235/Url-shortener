require "rails_helper"

RSpec.describe "URL API", type: :request do
  let(:user) { User.create!(email: "owner@example.com", password: "password123") }
  let(:token) do
    Doorkeeper::AccessToken.create(
      resource_owner_id: user.id,
      expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
      scopes: "user",
      use_refresh_token: true
    ).token
  end

  def auth_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end

  describe "POST /url/shorten" do
    it "creates a short URL for an authenticated user" do
      post "/url/shorten", params: { url: "https://example.com" }, headers: auth_headers(token)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body["short_url"]["url"]).to eq("https://example.com")
      expect(body["short_url"]["code"]).to be_present
      expect(user.short_urls.find_by(url: "https://example.com")).to be_present
    end

    it "returns unauthorized when no access token is provided" do
      post "/url/shorten", params: { url: "https://example.com" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns an error when the URL already exists" do
      user.short_urls.create!(url: "https://example.com")

      post "/url/shorten", params: { url: "https://example.com" }, headers: auth_headers(token)

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to be_present
    end
  end

  describe "POST /url/:code/notify" do
    let(:short_url) { user.short_urls.create!(url: "https://example.com") }

    before do
      ActionMailer::Base.deliveries.clear
    end

    it "sends a report email to the URL owner" do
      post "/url/#{short_url.code}/notify", headers: auth_headers(token)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Notification email sent")
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "returns unauthorized when no token is provided" do
      post "/url/#{short_url.code}/notify"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found when the authenticated user does not own the short URL" do
      other_user = User.create!(email: "other@example.com", password: "password123")
      other_token = Doorkeeper::AccessToken.create(
        resource_owner_id: other_user.id,
        expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
        scopes: "user",
        use_refresh_token: true
      ).token

      post "/url/#{short_url.code}/notify", headers: auth_headers(other_token)

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("URL not found")
    end

    it "returns not found for an invalid short code" do
      post "/url/invalidcode/notify", headers: auth_headers(token)

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("URL not found")
    end
  end
end
