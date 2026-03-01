# frozen_string_literal: true

class CreateDreamInterpretations < ActiveRecord::Migration[8.1]
  def change
    create_table :dream_interpretations do |t|
      # 꿈 원문 텍스트
      t.text :dream_text, null: false
      # 정규화된 키워드 (검색용)
      t.string :keywords_key, null: false
      # 해석 결과 JSON
      t.text :result_json, null: false
      # 사용 횟수
      t.integer :use_count, default: 1

      t.timestamps
    end

    add_index :dream_interpretations, :keywords_key
  end
end
