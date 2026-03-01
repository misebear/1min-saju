# frozen_string_literal: true

class CelebrityImage < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  # 이미지가 있는지 확인
  def has_image?
    image_url.present?
  end

  # 이미지가 오래되었는지 (7일 이상)
  def stale?
    fetched_at.nil? || fetched_at < 7.days.ago
  end

  # 캐시된 이미지 URL 가져오기 (없으면 nil)
  def self.cached_url(name)
    record = find_by(name: name)
    return record.image_url if record&.has_image? && !record.stale?
    nil
  end

  # 이미지 URL 저장
  def self.cache_image(name, url)
    record = find_or_initialize_by(name: name)
    record.update(image_url: url, fetched_at: Time.current)
    record
  end
end
