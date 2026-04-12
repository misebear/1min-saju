module ApplicationHelper
  def adsense_publisher_id
    ENV["ADSENSE_PUBLISHER_ID"].presence ||
      Rails.application.credentials.dig(:adsense, :publisher_id).presence
  rescue
    nil
  end

  def adsense_enabled?
    adsense_publisher_id.present?
  end

  def ga_measurement_id
    ENV["GA_MEASUREMENT_ID"].presence ||
      ENV["GOOGLE_ANALYTICS_ID"].presence ||
      Rails.application.credentials.dig(:analytics, :ga_measurement_id).presence
  rescue
    nil
  end

  def ga_enabled?
    ga_measurement_id.present?
  end
end
