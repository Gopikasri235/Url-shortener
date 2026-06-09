class Click < ApplicationRecord
  belongs_to :short_url
  validates :short_url_id, uniqueness: true
end
