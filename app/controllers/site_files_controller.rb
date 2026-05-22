# frozen_string_literal: true

class SiteFilesController < ActionController::Base
  DEFAULT_ADSENSE_PUBLISHER_ID = "ca-pub-9072876824288260"
  ANDROID_PACKAGE_NAME = "app.railway.up.app_1min_saju_production.twa"
  DEFAULT_ANDROID_SHA256_FINGERPRINT =
    "5B:32:E4:F3:C3:1A:F7:43:EA:0A:D1:37:30:8F:7D:90:3B:FC:FD:5E:24:C9:58:2F:64:53:BC:2E:36:52:83:C2"

  def ads_txt
    publisher_id = ENV["ADSENSE_PUBLISHER_ID"].presence ||
      Rails.application.credentials.dig(:adsense, :publisher_id).presence ||
      DEFAULT_ADSENSE_PUBLISHER_ID

    if publisher_id.present?
      # ads.txt expects the seller account as pub-..., while AdSense script/meta use ca-pub-...
      ads_txt_publisher_id = publisher_id.sub(/\Aca-/, "")
      render plain: "google.com, #{ads_txt_publisher_id}, DIRECT, f08c47fec0942fa0\n", content_type: "text/plain; charset=utf-8"
    else
      head :not_found
    end
  rescue
    ads_txt_publisher_id = DEFAULT_ADSENSE_PUBLISHER_ID.sub(/\Aca-/, "")
    render plain: "google.com, #{ads_txt_publisher_id}, DIRECT, f08c47fec0942fa0\n", content_type: "text/plain; charset=utf-8"
  end

  def assetlinks
    fingerprints = ENV.fetch("ANDROID_SHA256_CERT_FINGERPRINTS", DEFAULT_ANDROID_SHA256_FINGERPRINT)
      .split(",")
      .map(&:strip)
      .reject(&:blank?)
      .uniq

    render json: [
      {
        relation: [ "delegate_permission/common.handle_all_urls" ],
        target: {
          namespace: "android_app",
          package_name: ANDROID_PACKAGE_NAME,
          sha256_cert_fingerprints: fingerprints
        }
      }
    ]
  end
end
