# frozen_string_literal: true

# 별자리 운세 DB (12별자리 × 60일진 = 720개)
class GeminiZodiacFortune < ApplicationRecord
  validates :sign, presence: true
  validates :iljin, presence: true
  validates :sign, uniqueness: { scope: :iljin }

  # 별자리 + 일진으로 조회
  def self.lookup(sign, iljin)
    find_by(sign: sign, iljin: iljin)
  end
end
