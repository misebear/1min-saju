# 띠별 운세 DB (12띠 × 60일진 = 720개)
class CreateGeminiTtiFortunesAndMore < ActiveRecord::Migration[8.0]
  def change
    # 띠별 운세
    create_table :gemini_tti_fortunes do |t|
      t.string :animal, null: false      # 띠 (쥐띠, 소띠 등)
      t.string :iljin, null: false        # 일진 (甲子(갑자) 등)
      t.string :headline                  # 오늘의 한줄
      t.text :fortune_text                # 운세 텍스트
      t.string :lucky_point               # 럭키 포인트
      t.integer :tension_level            # 텐션 레벨 (1~100)
      t.timestamps
    end
    add_index :gemini_tti_fortunes, [ :animal, :iljin ], unique: true, name: 'idx_tti_animal_iljin'

    # 별자리 운세
    create_table :gemini_zodiac_fortunes do |t|
      t.string :sign, null: false         # 별자리 (양자리, 황소자리 등)
      t.string :iljin, null: false        # 일진
      t.string :headline                  # 오늘의 한줄
      t.text :fortune_text                # 운세 텍스트
      t.string :lucky_point               # 럭키 포인트
      t.integer :tension_level            # 텐션 레벨
      t.timestamps
    end
    add_index :gemini_zodiac_fortunes, [ :sign, :iljin ], unique: true, name: 'idx_zodiac_sign_iljin'

    # 타로 해설
    create_table :gemini_tarot_readings do |t|
      t.string :card_name, null: false    # 카드 한글명 (바보, 완드 에이스 등)
      t.string :card_en                   # 카드 영문명
      t.string :position, null: false     # 정위치/역위치
      t.string :keyword                   # 한줄 키워드
      t.text :reading_text                # 해설 텍스트
      t.text :advice                      # 어드바이스
      t.string :lucky_energy              # 럭키 에너지
      t.timestamps
    end
    add_index :gemini_tarot_readings, [ :card_name, :position ], unique: true, name: 'idx_tarot_card_pos'
  end
end
