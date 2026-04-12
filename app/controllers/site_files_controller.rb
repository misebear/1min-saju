# frozen_string_literal: true

class SiteFilesController < ActionController::Base
  def ads_txt
    publisher_id = ENV["ADSENSE_PUBLISHER_ID"].presence ||
      Rails.application.credentials.dig(:adsense, :publisher_id).presence

    if publisher_id.present?
      render plain: "google.com, #{publisher_id}, DIRECT, f08c47fec0942fa0\n", content_type: "text/plain; charset=utf-8"
    else
      head :not_found
    end
  rescue
    head :not_found
  end
end
