# frozen_string_literal: true

class CreateCelebrityImages < ActiveRecord::Migration[8.1]
  def change
    create_table :celebrity_images do |t|
      # 유명인 이름
      t.string :name, null: false
      # 이미지 URL (외부 서버)
      t.string :image_url
      # 이미지 가져온 시간
      t.datetime :fetched_at

      t.timestamps
    end

    add_index :celebrity_images, :name, unique: true
  end
end
