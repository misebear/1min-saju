# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

# 유명인 사진 검색 서비스
# Google Custom Search (무료 100회/일) 또는 위키피디아 API 사용
class CelebrityImageService
  WIKI_API = "https://ko.wikipedia.org/api/rest_v1/page/summary"

  # 유명인 사진 URL 가져오기 (캐시 우선)
  def self.fetch_image(name)
    # 1. DB 캐시 확인
    cached = CelebrityImage.cached_url(name)
    return cached if cached

    # 2. 위키피디아에서 검색 (무료, API 키 불필요)
    url = search_wikipedia(name)

    # 3. DB에 캐시
    if url
      CelebrityImage.cache_image(name, url)
    end

    url
  rescue StandardError => e
    Rails.logger.error("[CelebrityImageService] #{name} 검색 실패: #{e.message}")
    nil
  end

  # 여러 유명인 일괄 조회
  def self.fetch_images(names)
    result = {}
    names.each do |name|
      result[name] = fetch_image(name)
    end
    result
  end

  private

  # 위키피디아 REST API로 프로필 사진 검색
  def self.search_wikipedia(name)
    # 이름에서 불필요한 접두사 제거
    clean_name = clean_celebrity_name(name)

    # 한국어 위키피디아 먼저 시도
    url = wiki_request(clean_name)
    return url if url

    # 영어 이름으로도 시도 (유명한 해외 인물)
    english_name = ENGLISH_NAMES[clean_name]
    if english_name
      url = wiki_request(english_name, "en")
      return url if url
    end

    nil
  end

  def self.wiki_request(name, lang = "ko")
    base_url = "https://#{lang}.wikipedia.org/api/rest_v1/page/summary"
    encoded = URI.encode_www_form_component(name)
    uri = URI("#{base_url}/#{encoded}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 5
    http.open_timeout = 3

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "1MinSaju/1.0 (contact@1minsaju.com)"

    response = http.request(request)

    if response.code == "200"
      data = JSON.parse(response.body)
      # thumbnail 또는 originalimage 사용
      img = data.dig("thumbnail", "source") || data.dig("originalimage", "source")
      return img if img
    end

    nil
  rescue StandardError => e
    Rails.logger.debug("[CelebrityImageService] Wiki 검색 실패 (#{name}): #{e.message}")
    nil
  end

  # 이름 정리 (접두사, 그룹명 제거)
  def self.clean_celebrity_name(name)
    # "BTS 정국" → "정국", "블랙핑크 제니" → "제니", "GD 권지용" → "권지용"
    # "트와이스 나연" → "나연", "아이브 장원영" → "장원영"
    name = name.gsub(/^(BTS|방탄소년단|블랙핑크|트와이스|에스파|뉴진스|아이브|엔믹스|소녀시대|EXO)\s+/i, "")
    name = name.gsub(/^(GD|GDragon)\s+/i, "")
    name = name.gsub(/\(.+\)/, "").strip # "도경수(디오)" → "도경수"
    name
  end

  # 해외 인물 영어 이름 매핑
  ENGLISH_NAMES = {
    "나폴레옹" => "Napoleon",
    "아인슈타인" => "Albert Einstein",
    "빌게이츠" => "Bill Gates",
    "스티브 잡스" => "Steve Jobs",
    "마이클조던" => "Michael Jordan",
    "브루노마스" => "Bruno Mars",
    "이순신" => "Yi Sun-sin",
    "세종대왕" => "Sejong the Great"
  }.freeze
end
