# frozen_string_literal: true

class ZodiacController < ApplicationController
  def show
    if session[:birth_date].present?
      @birth_date = Date.parse(session[:birth_date])
      @sign_name = SajuEngine::ZodiacEngine.find_sign(@birth_date.month, @birth_date.day)
    else
      # 기본값: 오늘 날짜 기준 별자리
      @birth_date = Date.today
      @sign_name = SajuEngine::ZodiacEngine.find_sign(@birth_date.month, @birth_date.day)
    end

    @sign_info = SajuEngine::ZodiacEngine::ZODIAC_SIGNS[@sign_name]
    @fortune = SajuEngine::ZodiacEngine.daily_fortune(@sign_name)
    @all_signs = SajuEngine::ZodiacEngine::ZODIAC_SIGNS
  end
end
