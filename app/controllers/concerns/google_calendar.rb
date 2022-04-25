require "google/apis/calendar_v3"
require "google/api_client/client_secrets.rb"

module GoogleCalendar
  extend ActiveSupport::Concern
  def get_google_calendar_client(user)
    client = Google::Apis::CalendarV3::CalendarService.new
    return unless (user.present? && user.access_token.present? && user.refresh_token.present?)
    secrets = Google::APIClient::ClientSecrets.new({
      "web" => {
        "access_token" => user.access_token,
        "refresh_token" => user.refresh_token,
        "client_id" => ENV["GOOGLE_API_KEY"],
        "client_secret" => ENV["GOOGLE_API_SECRET"]
      }
    })
    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = "refresh_token"

      if !user.present?
        client.authorization.refresh!
        user.update_attributes(
          access_token: client.authorization.access_token,
          refresh_token: client.authorization.refresh_token,
          expires_at: client.authorization.expires_at.to_i
        )
      end
    rescue => e
      flash[:error] = "Your token has been expired. Please login again with google."
      redirect_to :back
    end
    client
  end
end
