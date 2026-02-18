# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if session[:birth_date].present?
      @birth_date = Date.parse(session[:birth_date])
      @birth_hour = session[:birth_hour].to_i
      @gender = session[:gender] || "남"

      @analysis = SajuEngine.full_analysis(@birth_date, @birth_hour, @gender)
      @daily = @analysis[:daily_fortune]
    end
  end
end
