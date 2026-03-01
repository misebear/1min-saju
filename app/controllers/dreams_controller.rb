# frozen_string_literal: true

class DreamsController < ApplicationController
  def new
  end

  def create
    @dream_text = params[:dream_text].to_s.strip
    if @dream_text.blank?
      redirect_to new_dream_path, alert: "꿈 내용을 입력해주세요!"
      return
    end

    session[:dream_text] = @dream_text
    redirect_to dream_result_path
  end

  def show
    @dream_text = session[:dream_text]
    redirect_to new_dream_path unless @dream_text.present?
    return unless @dream_text.present?

    # 키워드 추출
    keywords = SajuEngine::DreamEngine.find_keywords_public(@dream_text)

    # DB 캐시 확인 (동일 키워드 조합이면 캐시 사용)
    cached = DreamInterpretation.find_cached(keywords) if keywords.any?
    if cached
      @result = cached.parsed_result
      cached.increment!(:use_count)
    else
      @result = SajuEngine::DreamEngine.interpret(@dream_text)
      # DB에 캐시 저장
      DreamInterpretation.cache_result(@dream_text, keywords, @result) if keywords.any?
    end

    # 사주 정보가 있으면 오행 보조 해석 추가
    if session[:birth_date].present?
      birth_date = Date.parse(session[:birth_date])
      birth_hour = session[:birth_hour].to_i
      analysis = SajuEngine.full_analysis(birth_date, birth_hour, session[:gender] || "남")
      user_element = SajuEngine::HeavenlyStems.element(analysis[:saju][:day][:stem])
      @element_advice = SajuEngine::DreamEngine.element_advice(@result, user_element)
      @user_element = user_element
    end
  end
end
