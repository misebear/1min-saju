# frozen_string_literal: true

class SiteFilesController < ActionController::Base
  DEFAULT_ADSENSE_PUBLISHER_ID = "ca-pub-9072876824288260"

  def ads_txt
    publisher_id = ENV["ADSENSE_PUBLISHER_ID"].presence ||
      Rails.application.credentials.dig(:adsense, :publisher_id).presence ||
      DEFAULT_ADSENSE_PUBLISHER_ID

    if publisher_id.present?
      render plain: "google.com, #{publisher_id}, DIRECT, f08c47fec0942fa0\n", content_type: "text/plain; charset=utf-8"
    else
      head :not_found
    end
  rescue
    render plain: "google.com, #{DEFAULT_ADSENSE_PUBLISHER_ID}, DIRECT, f08c47fec0942fa0\n", content_type: "text/plain; charset=utf-8"
  end
end
