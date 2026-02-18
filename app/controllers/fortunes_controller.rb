# frozen_string_literal: true

class FortunesController < ApplicationController
  before_action :check_session

  def daily
    @analysis = load_analysis
    @daily = @analysis[:daily_fortune]
    @yearly = @analysis[:yearly_fortune]
  end

  def yearly
    @analysis = load_analysis
    @yearly = @analysis[:yearly_fortune]
    @major_fortune = @analysis[:major_fortune]
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
end
