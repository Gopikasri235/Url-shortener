class ShortUrlMailer < ApplicationMailer
  def url_report(short_url)
    @short_url = short_url
    @owner = short_url.user
    @click_count = short_url.click_count
    @short_url_link = "http://localhost:3000/url/#{short_url.code}"

    mail(to: @owner.email, subject: "Short URL report for #{short_url.code}")
  end
end
