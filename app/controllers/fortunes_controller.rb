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
end
