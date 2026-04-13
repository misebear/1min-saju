module ApplicationHelper
  DEFAULT_ADSENSE_PUBLISHER_ID = "ca-pub-9072876824288260"
  DEFAULT_GA_MEASUREMENT_ID = "G-TKM1ZR0J2W"

  def adsense_publisher_id
    ENV["ADSENSE_PUBLISHER_ID"].presence ||
      Rails.application.credentials.dig(:adsense, :publisher_id).presence ||
      DEFAULT_ADSENSE_PUBLISHER_ID
  rescue
    DEFAULT_ADSENSE_PUBLISHER_ID
  end

  def adsense_enabled?
    adsense_publisher_id.present?
  end

  def ga_measurement_id
    ENV["GA_MEASUREMENT_ID"].presence ||
      ENV["GOOGLE_ANALYTICS_ID"].presence ||
      Rails.application.credentials.dig(:analytics, :ga_measurement_id).presence ||
      DEFAULT_GA_MEASUREMENT_ID
  rescue
    DEFAULT_GA_MEASUREMENT_ID
  end

  def ga_enabled?
    ga_measurement_id.present?
  end
end
