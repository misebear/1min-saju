# frozen_string_literal: true

class AuspiciousDatesController < ApplicationController
  def new
    @purposes = SajuEngine::AuspiciousDateEngine::PURPOSE_CONFIG
  end

  def create
    @purpose = params[:purpose].to_s
    start_date = Date.parse(params[:start_date]) rescue Date.today
    end_date = Date.parse(params[:end_date]) rescue (Date.today + 30)

    # 최대 60일 범위 제한
    end_date = start_date + 60 if (end_date - start_date).to_i > 60

    session[:auspicious_purpose] = @purpose
    session[:auspicious_start] = start_date.to_s
    session[:auspicious_end] = end_date.to_s

    redirect_to auspicious_date_result_path
  end

  def show
    @purpose = session[:auspicious_purpose] || "이사"
    start_date = Date.parse(session[:auspicious_start] || Date.today.to_s)
    end_date = Date.parse(session[:auspicious_end] || (Date.today + 30).to_s)
    @config = SajuEngine::AuspiciousDateEngine::PURPOSE_CONFIG[@purpose]

    # 사용자 사주 정보
    user_birth = session[:birth_date].present? ? Date.parse(session[:birth_date]) : nil
    user_hour = session[:birth_hour].to_i

    @best_dates = SajuEngine::AuspiciousDateEngine.best_dates(
      @purpose, start_date, end_date, user_birth, user_hour
    )

    @all_dates = SajuEngine::AuspiciousDateEngine.find_dates(
      @purpose, start_date, end_date, user_birth, user_hour
    )

    @start_date = start_date
    @end_date = end_date
    @has_saju = session[:birth_date].present?
  end
end
