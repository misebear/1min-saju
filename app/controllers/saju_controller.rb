# frozen_string_literal: true

class SajuController < ApplicationController
  def new
    @city_options = SajuEngine::TimezoneCorrection.city_options
  end

  def create
    birth_date = Date.new(
      params[:year].to_i,
      params[:month].to_i,
      params[:day].to_i
    )
    birth_hour = params[:hour].to_i
    gender = params[:gender] || "남"
    city = params[:city] || "서울"

    # 세션에 저장
    session[:birth_date] = birth_date.to_s
    session[:birth_hour] = birth_hour
    session[:gender] = gender
    session[:city] = city

    redirect_to saju_result_path
  end

  def show
    redirect_to new_saju_path unless session[:birth_date].present?
    return unless session[:birth_date].present?

    birth_date = Date.parse(session[:birth_date])
    birth_hour = session[:birth_hour].to_i
    gender = session[:gender] || "남"
    city = session[:city] || "서울"

    # 시간 보정
    @correction = SajuEngine::TimezoneCorrection.correct(birth_date, birth_hour, city)
    corrected_hour = @correction[:corrected_hour]

    # 야자시 처리
    yajasi = SajuEngine::TimezoneCorrection.apply_yajasi(birth_date, corrected_hour)
    final_date = yajasi[:date]
    final_hour = yajasi[:hour]
    @yajasi = yajasi

    @analysis = SajuEngine.full_analysis(final_date, final_hour, gender)
    @ten_gods = @analysis[:ten_gods]
    @special_stars = @analysis[:special_stars]
    @major_fortune = @analysis[:major_fortune]
    @city = city
  end
end
