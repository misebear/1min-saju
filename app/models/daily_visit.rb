# 일별 방문자 수 모델
class DailyVisit < ApplicationRecord
  validates :visit_date, presence: true, uniqueness: true

  # 방문 기록 (페이지뷰 + 유니크 방문자)
  def self.track!(session)
    today = Date.current
    record = find_or_create_by(visit_date: today) do |r|
      r.visit_count = 0
      r.unique_visitors = 0
    end

    # 총 페이지뷰 증가
    record.increment!(:visit_count)

    # 세션 기반 유니크 방문자 (하루 1회만 카운트)
    unless session[:visited_today] == today.to_s
      record.increment!(:unique_visitors)
      session[:visited_today] = today.to_s
    end

    record
  end

  # 오늘 방문자 수
  def self.today_count
    find_by(visit_date: Date.current)&.visit_count || 0
  end

  # 오늘 유니크 방문자 수
  def self.today_unique
    find_by(visit_date: Date.current)&.unique_visitors || 0
  end

  # 어제 방문자 수
  def self.yesterday_count
    find_by(visit_date: Date.yesterday)&.visit_count || 0
  end

  # 총 누적 방문자 수
  def self.total_count
    sum(:visit_count)
  end
end
