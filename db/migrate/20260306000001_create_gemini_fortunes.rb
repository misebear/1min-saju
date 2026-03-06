# frozen_string_literal: true

# Gemini RPA로 수집한 3,600개 운세 데이터 저장 테이블
# 60갑자 일진 × 60갑자 일주 = 3,600개 조합
class CreateGeminiFortunes < ActiveRecord::Migration[8.1]
  def change
    create_table :gemini_fortunes do |t|
      t.string :today_iljin, null: false   # 오늘의 일진 (예: "甲子(갑자)")
      t.string :user_ilju, null: false     # 사용자 일주 (예: "乙丑(을축)")
      t.text :vibe, null: false            # 오늘의 바이브
      t.text :money                        # 머니 주파수
      t.text :relationship                 # 관계/플러팅
      t.string :lucky_item                 # 럭키 부적 아이템
      t.string :style                      # 오늘의 추구미
      t.timestamps
    end

    # 일진×일주 복합 유니크 인덱스 (빠른 조회 + 중복 방지)
    add_index :gemini_fortunes, [ :today_iljin, :user_ilju ], unique: true, name: "idx_gemini_fortunes_iljin_ilju"
  end
end
