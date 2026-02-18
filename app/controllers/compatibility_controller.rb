# frozen_string_literal: true

class CompatibilityController < ApplicationController
  def new
    # 궁합 입력 폼
  end

  def create
    # 입력값만 세션에 저장 (CookieOverflow 방지)
    session[:compat_params] = {
      year1: params[:year1], month1: params[:month1], day1: params[:day1],
      hour1: params[:hour1], gender1: params[:gender1] || "남",
      year2: params[:year2], month2: params[:month2], day2: params[:day2],
      hour2: params[:hour2], gender2: params[:gender2] || "여"
    }

    redirect_to compatibility_result_path
  end

  def show
    unless session[:compat_params].present?
      redirect_to new_compatibility_path
      return
    end

    cp = session[:compat_params]

    birth_date1 = Date.new(cp["year1"].to_i, cp["month1"].to_i, cp["day1"].to_i)
    birth_date2 = Date.new(cp["year2"].to_i, cp["month2"].to_i, cp["day2"].to_i)

    @person1 = SajuEngine.full_analysis(birth_date1, cp["hour1"].to_i, cp["gender1"])
    @person2 = SajuEngine.full_analysis(birth_date2, cp["hour2"].to_i, cp["gender2"])
    @compatibility = SajuEngine.compatibility(@person1, @person2)
  end
end
