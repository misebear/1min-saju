# 블라인드 궁합 링크 테이블
class CreateBlindCompatLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :blind_compat_links do |t|
      # 고유 토큰 (URL-safe)
      t.string :token, null: false, index: { unique: true }

      # 사용자 A (링크 생성자)
      t.date :person1_birth_date, null: false
      t.integer :person1_hour, default: 11
      t.string :person1_gender, default: "남"
      t.string :person1_name, default: ""

      # 사용자 B (상대방 — 매칭 후 채워짐)
      t.date :person2_birth_date
      t.integer :person2_hour
      t.string :person2_gender
      t.string :person2_name

      # 매칭 상태
      t.datetime :matched_at
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
