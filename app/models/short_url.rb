class ShortUrl < ApplicationRecord
  has_one :click, dependent: :delete
  belongs_to :user
  validates :code, uniqueness: true, presence: true
  validates :url, uniqueness: true, presence: true

  def click_count
    click&.count.to_i
  end

  def shareable_url
    "http://localhost:3000/url/#{code}"
  end

  before_validation :generate_short_code

  private

  def generate_short_code
    return if code.present?

    self.code = loop do
      token = SecureRandom.alphanumeric(8)
      break token unless ShortUrl.exists?(code: token)
    end
  end
end
