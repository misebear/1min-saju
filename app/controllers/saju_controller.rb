# frozen_string_literal: true

class SajuController < ApplicationController
  include FamousPeople

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

    # Famous people with similar day pillar
    saju = @analysis[:saju]
    @famous_people = find_famous_people(saju[:day][:stem], saju[:day][:branch])

    # DB에 기록 저장 (중복 방지: 같은 날 같은 생일이면 저장 안 함)
    unless SajuRecord.where(birth_date: birth_date, birth_hour: birth_hour, gender: gender)
                     .where("created_at >= ?", Date.today.beginning_of_day).exists?
      SajuRecord.create(
        birth_date: birth_date,
        birth_hour: birth_hour,
        gender: gender,
        city: city,
        result_json: @analysis.to_json
      )
    end
  end

  # 사주 기록 목록
  def history
    @records = SajuRecord.order(created_at: :desc).limit(50)
  end
end
