# 탄생석 컨트롤러
class BirthstoneController < ApplicationController
  def show
    birth_date = if session[:birth_date].present?
      Date.parse(session[:birth_date]) rescue Date.today
    else
      Date.today
    end
    @result = SajuEngine::BirthstoneEngine.analyze(birth_date)
  end
end
