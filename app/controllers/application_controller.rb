class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # 모든 페이지에서 세션에 저장된 사용자 생년월일 정보를 로드
  before_action :load_user_birth_info
  before_action :track_visit

  private

  # 방문자 수 추적
  def track_visit
    return unless request.format.html?
    begin
      DailyVisit.track!(session)
      @today_visitors = DailyVisit.today_unique
      @today_pageviews = DailyVisit.today_count
      @total_visitors = DailyVisit.total_count
    rescue => e
      Rails.logger.warn "방문자 추적 실패: #{e.message}"
      @today_visitors = 0
      @today_pageviews = 0
      @total_visitors = 0
    end
  end

  def load_user_birth_info
    if session[:birth_date].present?
      @user_birth_date = Date.parse(session[:birth_date]) rescue nil
      @user_birth_hour = session[:birth_hour].to_i
      @user_gender = session[:gender] || "남"
      @user_city = session[:city] || "서울"
      @has_birth_data = true

      # 간단한 표시용 정보 (모든 뷰에서 사용 가능)
      hour_names = {
        0 => "자시", 1 => "축시", 3 => "인시", 5 => "묘시",
        7 => "진시", 9 => "사시", 11 => "오시", 13 => "미시",
        15 => "신시", 17 => "유시", 19 => "술시", 21 => "해시"
      }
      @user_birth_label = "#{@user_birth_date&.strftime('%Y.%m.%d')} #{hour_names[@user_birth_hour] || ''} · #{@user_gender}"
    else
      @has_birth_data = false
    end
  end
end
