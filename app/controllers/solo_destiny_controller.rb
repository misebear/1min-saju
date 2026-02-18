# frozen_string_literal: true

class SoloDestinyController < ApplicationController
  def new
    # 인연 풀이 입력 폼
  end

  def create
    birth_date = Date.new(
      params[:year].to_i,
      params[:month].to_i,
      params[:day].to_i
    )
    birth_hour = params[:hour].to_i
    gender = params[:gender] || "남"

    session[:solo_birth_date] = birth_date.to_s
    session[:solo_birth_hour] = birth_hour
    session[:solo_gender] = gender

    redirect_to solo_destiny_result_path
  end

  def show
    unless session[:solo_birth_date].present?
      redirect_to new_solo_destiny_path
      return
    end

    birth_date = Date.parse(session[:solo_birth_date])
    birth_hour = session[:solo_birth_hour].to_i
    gender = session[:solo_gender] || "남"

    @analysis = SajuEngine.full_analysis(birth_date, birth_hour, gender)
    @archetype = SajuEngine::SoloDestiny.analyze_archetype(@analysis[:saju])
    @matches = SajuEngine::SoloDestiny.find_ideal_match(@analysis[:saju])
    @gender = gender
  end
end
