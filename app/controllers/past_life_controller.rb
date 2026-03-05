# 전생운 컨트롤러
class PastLifeController < ApplicationController
  def new; end

  def create
    birth_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    session[:past_life_params] = { year: params[:year], month: params[:month], day: params[:day], hour: params[:hour], gender: params[:gender] }
    redirect_to past_life_result_path
  end

  def show
    unless session[:past_life_params].present?
      redirect_to new_past_life_path; return
    end
    p = session[:past_life_params]
    birth_date = Date.new(p["year"].to_i, p["month"].to_i, p["day"].to_i)
    @result = SajuEngine::PastLifeEngine.analyze(birth_date, p["hour"].to_i, p["gender"])
  end
end
