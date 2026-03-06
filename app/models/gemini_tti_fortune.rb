# frozen_string_literal: true

# 띠별 운세 DB (12띠 × 60일진 = 720개)
class GeminiTtiFortune < ApplicationRecord
  validates :animal, presence: true
  validates :iljin, presence: true
  validates :animal, uniqueness: { scope: :iljin }

  # 띠 + 일진으로 조회
  def self.lookup(animal, iljin)
    find_by(animal: animal, iljin: iljin)
  end
end
