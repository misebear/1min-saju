# frozen_string_literal: true

class SajuRecord < ApplicationRecord
  validates :birth_date, presence: true
  validates :birth_hour, presence: true, numericality: { in: 0..23 }
  validates :gender, inclusion: { in: %w[남 여] }

  # JSON 결과 파싱
  def parsed_result
    return {} if result_json.blank?
    JSON.parse(result_json, symbolize_names: true)
  rescue JSON::ParserError
    {}
  end

  # 일주 요약
  def day_pillar_summary
    result = parsed_result
    saju = result[:saju]
    return "정보 없음" unless saju
    "#{saju.dig(:day, :stem)}#{saju.dig(:day, :branch)}일주"
  end
end
