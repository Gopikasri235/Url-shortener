class UrlController < ApplicationController
  before_action :doorkeeper_authorize!, only: %i[short_code notify]
  before_action :set_user, only: %i[short_code notify]

  def short_code
    short_url = @user.short_urls.create!(short_code_params)
    render json: {
      short_url: {
        url: short_url.url,
        short_url: "http://localhost:3000/url/#{short_url.code}",
        code: short_url.code
      }
    }
  end

  def notify
    short_url = @user.short_urls.find_by(code: params[:code])
    return render json: { error: 'URL not found' }, status: :not_found if short_url.nil?

    ShortUrlMailer.url_report(short_url).deliver_now

    render json: { message: 'Notification email sent' }, status: :ok
  end

  def redirect
    short_url = ShortUrl.find_by(code: params[:code])
    return render json: { error: 'URL not found' }, status: :not_found if short_url.nil?

    click = short_url.click || short_url.create_click
    click.increment!(:count)

    redirect_to short_url.url, allow_other_host: true
  end

  private

  def short_code_params
    params.permit(:url)
  end

  def set_user
    @user = User.find_by(id: doorkeeper_token.resource_owner_id) unless doorkeeper_token.blank?
  end
end
