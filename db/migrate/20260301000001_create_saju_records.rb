# frozen_string_literal: true

class CreateSajuRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :saju_records do |t|
      # 사용자 이름 (선택)
      t.string :name, default: ""
      # 생년월일 정보
      t.date :birth_date, null: false
      t.integer :birth_hour, null: false
      t.string :gender, default: "남"
      t.string :city, default: "서울"
      # 분석 결과 (JSON)
      t.text :result_json
      # 메모
      t.string :memo, default: ""

      t.timestamps
    end

    add_index :saju_records, :birth_date
    add_index :saju_records, :created_at
  end
end
