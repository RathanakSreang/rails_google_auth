module ApplicationHelper
  def map_alert_key(key)
    keys = {
      notice: "success",
      alert: "danger"
    }

    keys[key.to_sym] || key
  end
end
