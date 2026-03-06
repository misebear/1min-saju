# frozen_string_literal: true

class FortunesController < ApplicationController
  before_action :check_session

  def daily
    @analysis = load_analysis
    @daily = @analysis[:daily_fortune]
    @yearly = @analysis[:yearly_fortune]

    # Gemini DB에서 고퀄리티 운세 조회
    @gemini_fortune = lookup_gemini_fortune
  end

  def yearly
    @analysis = load_analysis
    @yearly = @analysis[:yearly_fortune]
    @major_fortune = @analysis[:major_fortune]
  end

  def tomorrow
    @analysis = load_analysis
    @daily = @analysis[:daily_fortune]
    @target_date = Date.tomorrow
  end

  def specific_form; end

  def specific
    @target_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @analysis = load_analysis
    @daily = @analysis[:daily_fortune]
    render :specific_result
  rescue
    redirect_to specific_fortune_form_path
  end

  private

  def check_session
    redirect_to new_saju_path unless session[:birth_date].present?
  end

  def load_analysis
    birth_date = Date.parse(session[:birth_date])
    birth_hour = session[:birth_hour].to_i
    gender = session[:gender] || "남"
    SajuEngine.full_analysis(birth_date, birth_hour, gender)
  end

  # Gemini DB에서 오늘 일진 × 사용자 일주 조합의 운세 조회
  def lookup_gemini_fortune
    # 오늘의 일진 (오늘 날짜의 일주)
    today_pillar = SajuEngine::PillarCalculator.calculate_day_pillar(Date.today)
    today_iljin = pillar_to_iljin(today_pillar[:stem], today_pillar[:branch])

    # 사용자의 일주 (생년월일의 일주)
    birth_date = Date.parse(session[:birth_date])
    user_pillar = SajuEngine::PillarCalculator.calculate_day_pillar(birth_date)
    user_ilju = pillar_to_iljin(user_pillar[:stem], user_pillar[:branch])

    GeminiFortune.lookup(today_iljin, user_ilju)
  rescue => e
    Rails.logger.warn("Gemini 운세 조회 실패: #{e.message}")
    nil
  end

  # 한글 천간/지지를 CSV 형식 "甲子(갑자)"로 변환
  def pillar_to_iljin(stem, branch)
    stem_idx = SajuEngine::HeavenlyStems::STEMS.index(stem)
    branch_idx = SajuEngine::EarthlyBranches::BRANCHES.index(branch)
    hanja_stem = SajuEngine::HeavenlyStems::STEMS_HANJA[stem_idx]
    hanja_branch = SajuEngine::EarthlyBranches::BRANCHES_HANJA[branch_idx]
    "#{hanja_stem}#{hanja_branch}(#{stem}#{branch})"
  end
end
