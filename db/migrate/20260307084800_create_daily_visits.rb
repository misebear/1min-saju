# 일별 방문자 수 추적 테이블
class CreateDailyVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_visits do |t|
      t.date :visit_date, null: false
      t.integer :visit_count, default: 0, null: false
      t.integer :unique_visitors, default: 0, null: false
      t.timestamps
    end

    add_index :daily_visits, :visit_date, unique: true
  end
end
