# frozen_string_literal: true

class DreamInterpretation < ApplicationRecord
  validates :dream_text, presence: true
  validates :keywords_key, presence: true
  validates :result_json, presence: true

  # 키워드 조합으로 캐시된 해석 찾기
  def self.find_cached(keywords)
    key = normalize_key(keywords)
    find_by(keywords_key: key)
  end

  # 해석 결과 캐시 저장
  def self.cache_result(dream_text, keywords, result)
    key = normalize_key(keywords)
    record = find_or_initialize_by(keywords_key: key)
    if record.persisted?
      record.increment!(:use_count)
    else
      record.update(
        dream_text: dream_text,
        result_json: result.to_json,
        use_count: 1
      )
    end
    record
  end

  # 캐시된 결과 가져오기 (JSON → Hash)
  def parsed_result
    JSON.parse(result_json, symbolize_names: true)
  end

  private

  def self.normalize_key(keywords)
    keywords.sort.join(",")
  end
end
