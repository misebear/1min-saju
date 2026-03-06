# frozen_string_literal: true

# Gemini RPA로 수집한 고퀄리티 운세 데이터
# 60갑자 일진 × 60갑자 일주 = 최대 3,600개 조합
class GeminiFortune < ApplicationRecord
  validates :today_iljin, presence: true
  validates :user_ilju, presence: true
  validates :vibe, presence: true
  validates :today_iljin, uniqueness: { scope: :user_ilju }

  # 오늘의 일진 + 사용자 일주로 운세 조회
  # @param iljin [String] 오늘의 일진 (예: "甲子(갑자)")
  # @param ilju [String] 사용자의 일주 (예: "乙丑(을축)")
  # @return [GeminiFortune, nil]
  def self.lookup(iljin, ilju)
    find_by(today_iljin: iljin, user_ilju: ilju)
  end

  # 오늘 날짜의 일진으로 조회 가능한 운세 개수
  def self.available_count_for(iljin)
    where(today_iljin: iljin).count
  end
end
