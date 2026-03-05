# 심리풀이 컨트롤러
class PsychologyController < ApplicationController
  def new
    @questions = SajuEngine::PsychologyEngine.questions
  end

  def create
    answers = [params[:q1], params[:q2], params[:q3], params[:q4]]
    session[:psychology_answers] = answers
    redirect_to psychology_result_path
  end

  def show
    unless session[:psychology_answers].present?
      redirect_to new_psychology_path; return
    end
    @result = SajuEngine::PsychologyEngine.analyze(session[:psychology_answers])
  end
end
