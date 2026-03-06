# 궁합 DB 마이그레이션 - 일주A × 일주B 조합별 궁합 텍스트 저장
class CreateGeminiCompatibilities < ActiveRecord::Migration[8.0]
  def change
    create_table :gemini_compatibilities do |t|
      t.string :ilju_a, null: false       # A의 일주 (예: "甲子(갑자)")
      t.string :ilju_b, null: false       # B의 일주 (예: "乙丑(을축)")
      t.integer :chemistry_score           # 케미 점수 (1~100)
      t.string :chemistry_type             # 케미 타입 (불꽃 케미, 힐링 케미 등)
      t.text :analysis                     # 종합 분석 (200자)
      t.text :dating_style                 # 연애 스타일 (100자)
      t.text :caution_point                # 주의 포인트 (100자)
      t.string :lucky_date                 # 럭키 데이트 (한강 피크닉 등)
      t.timestamps
    end

    # 일주A × 일주B 유니크 인덱스
    add_index :gemini_compatibilities, [ :ilju_a, :ilju_b ], unique: true, name: 'idx_compat_ilju_pair'
    # 개별 검색용
    add_index :gemini_compatibilities, :ilju_a
    add_index :gemini_compatibilities, :ilju_b
  end
end
