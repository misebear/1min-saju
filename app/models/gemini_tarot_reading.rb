# frozen_string_literal: true

# 타로 해설 DB (78장 × 정/역 = 156개)
class GeminiTarotReading < ApplicationRecord
  validates :card_name, presence: true
  validates :position, presence: true
  validates :card_name, uniqueness: { scope: :position }

  # 카드명 + 정/역위치로 조회
  def self.lookup(card_name, position)
    find_by(card_name: card_name, position: position)
  end
end
