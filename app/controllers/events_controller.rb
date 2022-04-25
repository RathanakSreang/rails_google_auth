class EventsController < ApplicationController
  include GoogleCalendar
  before_action :authenticate_user!

  def index
    @events_list = get_events_list
  end

  private

  def get_events_list
    cache_key = "#{current_user.id}_events_list"
    events_list = Rails.cache.read(cache_key)
    return events_list if events_list

    client = get_google_calendar_client(current_user)
    calendar_id = "primary"
    response = client.list_events(calendar_id,
                               max_results:   10,
                               single_events: true,
                               order_by:      "startTime",
                               time_min:      DateTime.now.rfc3339)
    items = response.items.map do |event|
      start = event.start.date || event.start.date_time
      {
        start: start,
        summary: event.summary
      }
    end

    Rails.cache.write(cache_key, items, expires_in: 5.minute)
    items
  end
end
