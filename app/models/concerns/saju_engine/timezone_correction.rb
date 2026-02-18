# frozen_string_literal: true

module SajuEngine
  module TimezoneCorrection
    # ─── 한국 서머타임(일광절약시간) 실시 기간 ───
    # 한국은 1948~1988년 사이 간헐적으로 서머타임을 실시했습니다.
    # 서머타임 기간 중 출생한 경우, 실제 태양시보다 1시간 빠르므로 -1시간 보정 필요
    KOREAN_DST_PERIODS = [
      # [시작일, 종료일] — 양력 기준
      { year: 1948, start: [ 6, 1 ],  end: [ 9, 12 ] },
      { year: 1949, start: [ 4, 3 ],  end: [ 9, 10 ] },
      { year: 1950, start: [ 4, 1 ],  end: [ 9, 9 ]  },
      { year: 1951, start: [ 5, 6 ],  end: [ 9, 8 ]  },
      { year: 1952, start: [ 5, 4 ],  end: [ 9, 13 ] },
      { year: 1953, start: [ 4, 5 ],  end: [ 9, 12 ] },
      { year: 1954, start: [ 3, 21 ], end: [ 9, 11 ] },
      { year: 1955, start: [ 5, 5 ],  end: [ 9, 8 ]  },
      { year: 1956, start: [ 5, 20 ], end: [ 9, 29 ] },
      { year: 1957, start: [ 5, 5 ],  end: [ 9, 21 ] },
      { year: 1958, start: [ 5, 4 ],  end: [ 9, 20 ] },
      { year: 1959, start: [ 5, 3 ],  end: [ 9, 19 ] },
      { year: 1960, start: [ 5, 1 ],  end: [ 9, 17 ] },
      { year: 1961, start: [ 5, 6 ],  end: [ 10, 7 ] }, # 이후 중단
      # 1987~1988 재실시
      { year: 1987, start: [ 5, 10 ], end: [ 10, 11 ] },
      { year: 1988, start: [ 5, 8 ],  end: [ 10, 9 ]  }
    ].freeze

    # ─── 주요 도시 경도 데이터 ───
    # 한국 표준시(KST)는 동경 135° 기준이지만,
    # 실제 한국 영토는 동경 126°~130° 사이에 위치합니다.
    # 경도 1° = 4분의 시간차이 → 서울(127°)은 표준 대비 약 -32분
    STANDARD_LONGITUDE = 135.0  # KST 기준 경도

    CITY_DATA = {
      "서울"   => { longitude: 126.98, label: "서울특별시" },
      "부산"   => { longitude: 129.03, label: "부산광역시" },
      "대구"   => { longitude: 128.60, label: "대구광역시" },
      "인천"   => { longitude: 126.70, label: "인천광역시" },
      "광주"   => { longitude: 126.85, label: "광주광역시" },
      "대전"   => { longitude: 127.39, label: "대전광역시" },
      "울산"   => { longitude: 129.31, label: "울산광역시" },
      "세종"   => { longitude: 127.00, label: "세종특별자치시" },
      "수원"   => { longitude: 127.01, label: "수원시" },
      "제주"   => { longitude: 126.53, label: "제주특별자치도" },
      "춘천"   => { longitude: 127.73, label: "춘천시" },
      "강릉"   => { longitude: 128.90, label: "강릉시" },
      "전주"   => { longitude: 127.15, label: "전주시" },
      "청주"   => { longitude: 127.49, label: "청주시" },
      "포항"   => { longitude: 129.37, label: "포항시" },
      "평양"   => { longitude: 125.75, label: "평양" },
      "해외"   => { longitude: 135.00, label: "해외 (보정 없음)" },
      "모름"   => { longitude: 135.00, label: "모름 (보정 없음)" }
    }.freeze

    # ─── 보정 메서드 ───

    # 출생 시간 보정 (모든 보정 요소 적용)
    # @param birth_date [Date] 생년월일
    # @param birth_hour [Integer] 출생 시간 (0~23)
    # @param city [String] 출생 도시
    # @param options [Hash] 추가 옵션 { dst: true/false, local_time: true/false }
    # @return [Hash] { corrected_hour:, corrections: [], total_minutes: }
    def self.correct(birth_date, birth_hour, city = "서울", options = {})
      corrections = []
      total_minutes = 0

      # 1. 서머타임 보정
      if options.fetch(:dst, true)
        dst_minutes = dst_correction(birth_date)
        if dst_minutes != 0
          total_minutes += dst_minutes
          corrections << {
            type: :dst,
            minutes: dst_minutes,
            label: "☀️ 서머타임 #{dst_minutes > 0 ? '+' : ''}#{dst_minutes}분 보정"
          }
        end
      end

      # 2. 지역 시차 보정 (진태양시)
      if options.fetch(:local_time, true) && city != "모름" && city != "해외"
        local_minutes = local_time_correction(city)
        if local_minutes.abs >= 1
          total_minutes += local_minutes
          corrections << {
            type: :local,
            minutes: local_minutes,
            label: "📍 #{city} 시차 #{local_minutes > 0 ? '+' : ''}#{local_minutes}분 보정"
          }
        end
      end

      # 보정된 시간 계산
      total_birth_minutes = birth_hour * 60 + total_minutes
      corrected_hour = (total_birth_minutes / 60.0).floor.clamp(0, 23)

      {
        original_hour: birth_hour,
        corrected_hour: corrected_hour,
        corrections: corrections,
        total_minutes: total_minutes,
        summary: corrections.map { |c| c[:label] }.join(" | "),
        applied: corrections.any?
      }
    end

    # 서머타임 적용 여부 확인 및 보정 분 반환
    def self.dst_correction(birth_date)
      period = KOREAN_DST_PERIODS.find do |p|
        next false unless p[:year] == birth_date.year

        start_date = Date.new(p[:year], p[:start][0], p[:start][1])
        end_date = Date.new(p[:year], p[:end][0], p[:end][1])
        birth_date >= start_date && birth_date <= end_date
      end

      period ? -60 : 0  # 서머타임 중이면 -60분 (1시간 뒤로)
    end

    # 지역 시차 보정 분 반환
    def self.local_time_correction(city)
      city_info = CITY_DATA[city]
      return 0 unless city_info

      # 경도 차이 × 4분/도
      diff_degrees = city_info[:longitude] - STANDARD_LONGITUDE
      (diff_degrees * 4).round
    end

    # 도시 목록 (뷰에서 select용)
    def self.city_options
      CITY_DATA.map { |key, data| [ data[:label], key ] }
    end

    # 야자시(夜子時) 처리
    # 자시를 23:00~01:00으로 보는 전통적 방법
    # 야자시: 23:00~24:00은 다음날 자시로 처리
    def self.apply_yajasi(birth_date, birth_hour, use_yajasi = false)
      if use_yajasi && birth_hour >= 23
        # 야자시: 23시 이후는 다음 날의 자시(子時)로 봄
        { date: birth_date + 1, hour: 0, applied: true,
          label: "🌙 야자시 적용 — 23시 이후는 다음 날 자시로 계산" }
      else
        { date: birth_date, hour: birth_hour, applied: false, label: nil }
      end
    end
  end
end
