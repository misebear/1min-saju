# frozen_string_literal: true

# Gemini AI가 생성한 궁합 DB (60일주 × 60일주 = 3,600개)
class GeminiCompatibility < ApplicationRecord
  validates :ilju_a, presence: true
  validates :ilju_b, presence: true
  validates :ilju_a, uniqueness: { scope: :ilju_b }

  # 두 사람의 일주로 궁합 조회
  # 정방향(A,B)과 역방향(B,A) 모두 검색
  def self.lookup(ilju_a, ilju_b)
    find_by(ilju_a: ilju_a, ilju_b: ilju_b) ||
      find_by(ilju_a: ilju_b, ilju_b: ilju_a)
  end
end
