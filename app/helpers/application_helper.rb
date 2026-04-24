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

  def faq_schema_json(items)
    {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => items.map do |item|
        {
          "@type" => "Question",
          "name" => item.fetch(:question),
          "acceptedAnswer" => {
            "@type" => "Answer",
            "text" => item.fetch(:answer)
          }
        }
      end
    }.to_json
  end

  def item_list_schema_json(name:, items:)
    {
      "@context" => "https://schema.org",
      "@type" => "ItemList",
      "name" => name,
      "itemListElement" => items.each_with_index.map do |item, index|
        {
          "@type" => "ListItem",
          "position" => index + 1,
          "name" => item.fetch(:name),
          "url" => item.fetch(:url)
        }
      end
    }.to_json
  end

  def track_click_data(event:, page_type:, source_section:, target_tool:)
    {
      data: {
        analytics_event: event,
        analytics_page_type: page_type,
        analytics_source_section: source_section,
        analytics_target_tool: target_tool
      }
    }
  end
end
