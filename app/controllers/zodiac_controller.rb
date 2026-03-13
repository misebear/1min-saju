# frozen_string_literal: true

class ZodiacController < ApplicationController
  def show
    if params[:sign].present?
      @sign_name = params[:sign]
    elsif session[:birth_date].present?
      @birth_date = Date.parse(session[:birth_date])
      @sign_name = SajuEngine::ZodiacEngine.find_sign(@birth_date.month, @birth_date.day)
    else
      # 기본값: 오늘 날짜 기준 별자리
      @birth_date = Date.today
      @sign_name = SajuEngine::ZodiacEngine.find_sign(@birth_date.month, @birth_date.day)
    end

    @sign_info = SajuEngine::ZodiacEngine::ZODIAC_SIGNS[@sign_name]
    @fortune = SajuEngine::ZodiacEngine.daily_fortune(@sign_name)
    @gemini_zodiac_fortune = lookup_gemini_zodiac_fortune(@sign_name)
    if @gemini_zodiac_fortune&.tension_level.present?
      @fortune[:score] = @gemini_zodiac_fortune.tension_level
      @fortune[:mood] = @gemini_zodiac_fortune.headline if @gemini_zodiac_fortune.headline.present?
    end
    @all_signs = SajuEngine::ZodiacEngine::ZODIAC_SIGNS
  end
end
