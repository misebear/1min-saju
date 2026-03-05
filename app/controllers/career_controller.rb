# 취업운 컨트롤러
class CareerController < ApplicationController
  def new; end

  def create
    birth_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    session[:career_params] = { year: params[:year], month: params[:month], day: params[:day], hour: params[:hour], gender: params[:gender] }
    redirect_to career_result_path
  end

  def show
    unless session[:career_params].present?
      redirect_to new_career_path; return
    end
    p = session[:career_params]
    birth_date = Date.new(p["year"].to_i, p["month"].to_i, p["day"].to_i)
    @result = SajuEngine::CareerEngine.analyze(birth_date, p["hour"].to_i, p["gender"])
  end
end
