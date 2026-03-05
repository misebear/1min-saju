# 타로 컨트롤러
class TarotController < ApplicationController
  def new; end

  def create
    birth_date = if session[:birth_date].present?
      Date.parse(session[:birth_date]) rescue Date.today
    else
      Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i) rescue Date.today
    end
    spread = (params[:spread] || "three_card").to_sym
    session[:tarot_params] = { birth_date: birth_date.to_s, spread: spread.to_s }
    redirect_to tarot_result_path
  end

  def show
    unless session[:tarot_params].present?
      redirect_to new_tarot_path; return
    end
    p = session[:tarot_params]
    birth_date = Date.parse(p["birth_date"]) rescue Date.today
    spread = (p["spread"] || "three_card").to_sym
    @result = SajuEngine::TarotEngine.draw(birth_date, spread)
  end
end
