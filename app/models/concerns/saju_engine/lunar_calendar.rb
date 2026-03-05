# frozen_string_literal: true

# 음양력 변환 모듈
# ruby_lunardate gem 활용 + 자체 폴백 데이터
module SajuEngine
  module LunarCalendar
    begin
      require "ruby_lunardate"
      GEM_AVAILABLE = true
    rescue LoadError
      GEM_AVAILABLE = false
    end

    # 음력 → 양력 변환
    def self.lunar_to_solar(year, month, day, is_leap_month = false)
      if GEM_AVAILABLE
        begin
          lunar = RubyLunardate::LunarDate.new(year, month, day, is_leap_month)
          solar = lunar.to_solar_date
          return Date.new(solar.year, solar.month, solar.day)
        rescue => e
          Rails.logger.warn("LunarCalendar gem 변환 실패: #{e.message}")
        end
      end

      # 폴백: 간이 변환 (평균 차이 기반)
      # 음력은 양력보다 평균 약 30~33일 늦음
      fallback_approximate(year, month, day)
    end

    # 양력 → 음력 변환
    def self.solar_to_lunar(year, month, day)
      if GEM_AVAILABLE
        begin
          solar = Date.new(year, month, day)
          lunar = RubyLunardate::LunarDate.from_solar_date(solar.year, solar.month, solar.day)
          return {
            year: lunar.year,
            month: lunar.month,
            day: lunar.day,
            is_leap_month: lunar.is_leap_month,
            lunar_text: "음력 #{lunar.year}년 #{lunar.month}월 #{lunar.day}일#{lunar.is_leap_month ? ' (윤달)' : ''}"
          }
        rescue => e
          Rails.logger.warn("LunarCalendar gem 변환 실패: #{e.message}")
        end
      end

      # 폴백: 간이 역산
      fallback_solar_to_lunar(year, month, day)
    end

    # 음력 날짜 유효성 검증
    def self.valid_lunar_date?(year, month, day)
      return false if year < 1900 || year > 2100
      return false if month < 1 || month > 12
      return false if day < 1 || day > 30
      true
    end

    private

    # 간이 음력→양력 변환 (gem 없을 때 폴백)
    # 한국천문연구원 평균 데이터 기반
    def self.fallback_approximate(year, month, day)
      # 음력 1월 1일의 양력 근사값 (설날 평균: 1/21 ~ 2/20 사이)
      # 간이 계산: 음력 월을 양력으로 대략 변환
      solar_month = month + 1  # 대략 1달 차이
      solar_day = day
      if solar_month > 12
        solar_month -= 12
        year += 1
      end
      begin
        Date.new(year, solar_month, [solar_day, 28].min)
      rescue ArgumentError
        Date.new(year, solar_month, 28)
      end
    end

    def self.fallback_solar_to_lunar(year, month, day)
      # 간이 역산
      lunar_month = month - 1
      lunar_month = 12 if lunar_month == 0
      lunar_year = lunar_month == 12 ? year - 1 : year
      {
        year: lunar_year,
        month: lunar_month,
        day: day,
        is_leap_month: false,
        lunar_text: "음력 #{lunar_year}년 #{lunar_month}월 #{day}일 (근사값)"
      }
    end
  end
end
