# frozen_string_literal: true

class HomeController < ApplicationController
  include FamousPeople

  def index
    if session[:birth_date].present?
      @birth_date = Date.parse(session[:birth_date])
      @birth_hour = session[:birth_hour].to_i
      @gender = session[:gender] || "남"

      @analysis = SajuEngine.full_analysis(@birth_date, @birth_hour, @gender)
      @daily = @analysis[:daily_fortune]

      # Famous people with similar day pillar
      saju = @analysis[:saju]
      @famous_people = find_famous_people(saju[:day][:stem], saju[:day][:branch])
    end
  end
end
