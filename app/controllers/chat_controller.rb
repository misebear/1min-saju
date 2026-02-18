# frozen_string_literal: true

class ChatController < ApplicationController
  def show
    unless session[:birth_date].present?
      redirect_to new_saju_path, notice: "먼저 생년월일을 입력해줘! 🐱"
      return
    end

    load_analysis
  end

  def message
    unless session[:birth_date].present?
      render json: { messages: [ "먼저 사주풀이를 해줘야 채팅할 수 있어! 🐱" ] }
      return
    end

    load_analysis
    question = params[:question].to_s.strip

    if question.empty?
      render json: { messages: [ "뭐가 궁금해? 아래 버튼을 눌러도 되고, 직접 물어봐도 돼! 😸" ] }
      return
    end

    messages = SajuEngine::ChatEngine.respond(question, @analysis)
    render json: { messages: messages }
  end

  private

  def load_analysis
    birth_date = Date.parse(session[:birth_date])
    birth_hour = session[:birth_hour].to_i
    gender = session[:gender] || "남"

    @analysis = SajuEngine.full_analysis(birth_date, birth_hour, gender)
  end
end
