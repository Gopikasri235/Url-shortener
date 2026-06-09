require "rails_helper"

RSpec.describe "URL redirect", type: :request do
  let(:user) { User.create!(email: "owner@example.com", password: "password123") }
  let(:short_url) { ShortUrl.create!(url: "https://example.com", user: user) }

  it "redirects to the original URL and increments click count" do
    get "/url/#{short_url.code}"

    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("https://example.com")
    expect(short_url.reload.click.count).to eq(1)
  end

  it "returns not found for an invalid short code" do
    get "/url/invalidcode"

    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)["error"]).to eq("URL not found")
  end
end
