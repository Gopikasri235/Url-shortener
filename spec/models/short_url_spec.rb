require "rails_helper"

RSpec.describe ShortUrl, type: :model do
  let(:user) { User.create!(email: "owner@example.com", password: "password123") }

  it "is valid with a url and user" do
    short_url = described_class.new(url: "https://example.com", user: user)

    expect(short_url).to be_valid
  end

  it "requires a url" do
    short_url = described_class.new(user: user)

    expect(short_url).not_to be_valid
    expect(short_url.errors[:url]).to include("can't be blank")
  end

  it "generates a unique short code before validation" do
    short_url = described_class.create!(url: "https://example.com", user: user)

    expect(short_url.code).to be_present
    expect(short_url.code.length).to eq(8)
  end

  it "enforces url uniqueness" do
    described_class.create!(url: "https://example.com", user: user)
    duplicate = described_class.new(url: "https://example.com", user: user)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:url]).to include("has already been taken")
  end
end
