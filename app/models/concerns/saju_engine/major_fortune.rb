# frozen_string_literal: true

# 대운(大運) 계산 모듈
# 사주팔자에서 10년 단위 운세 변화를 계산
module SajuEngine
  module MajorFortune
    # 대운 계산
    # @param saju [Hash] PillarCalculator.calculate 결과
    # @param birth_date [Date] 생년월일
    # @return [Array<Hash>] 대운 목록 (10개, 각 10년)
    def self.calculate(saju, birth_date)
      gender = saju[:gender]
      year_stem = saju[:year][:stem]

      # 대운 순행/역행 결정
      # 남자: 양년생(甲丙戊庚壬) → 순행, 음년생(乙丁己辛癸) → 역행
      # 여자: 양년생 → 역행, 음년생 → 순행
      year_yinyang = HeavenlyStems.yinyang(year_stem)
      forward = if gender == "남"
        year_yinyang == "양"
      else
        year_yinyang == "음"
      end

      # 대운 시작 나이 계산 (출생일 → 다음/이전 절기까지 일수 ÷ 3)
      start_age = calculate_start_age(birth_date, forward)

      # 월주 기준으로 대운 간지 생성
      month_stem_idx = saju[:month][:stem_index]
      month_branch_idx = saju[:month][:branch_index]

      fortunes = []
      10.times do |i|
        if forward
          stem_idx = (month_stem_idx + i + 1) % 10
          branch_idx = (month_branch_idx + i + 1) % 12
        else
          stem_idx = (month_stem_idx - i - 1) % 10
          branch_idx = (month_branch_idx - i - 1) % 12
        end

        stem = HeavenlyStems.from_index(stem_idx)
        branch = EarthlyBranches.from_index(branch_idx)
        element = HeavenlyStems.element(stem)

        age_start = start_age + (i * 10)
        age_end = age_start + 9
        year_start = birth_date.year + age_start
        year_end = birth_date.year + age_end

        fortunes << {
          order: i + 1,
          stem: stem,
          branch: branch,
          stem_index: stem_idx,
          branch_index: branch_idx,
          element: element,
          yinyang: HeavenlyStems.yinyang(stem),
          age_start: age_start,
          age_end: age_end,
          year_start: year_start,
          year_end: year_end,
          period: "#{age_start}~#{age_end}세 (#{year_start}~#{year_end})",
          description: fortune_description(stem, branch, element)
        }
      end

      {
        direction: forward ? "순행" : "역행",
        start_age: start_age,
        fortunes: fortunes,
        current: find_current_fortune(fortunes, birth_date)
      }
    end

    private

    # 대운 시작 나이 계산
    def self.calculate_start_age(birth_date, forward)
      # 다음(순행) 또는 이전(역행) 절기까지의 일수를 3으로 나눔
      # 1일 = 4개월로 환산
      year = birth_date.year

      if forward
        # 다음 절기 찾기
        next_term = find_next_term(birth_date)
        days_to_term = (next_term - birth_date).to_i.abs
      else
        # 이전 절기 찾기
        prev_term = find_prev_term(birth_date)
        days_to_term = (birth_date - prev_term).to_i.abs
      end

      # 3일 = 1년으로 환산 (전통 계산법)
      age = (days_to_term / 3.0).round
      [age, 1].max  # 최소 1세
    end

    # 다음 절기 날짜 찾기
    def self.find_next_term(date)
      SolarTermsData::MONTH_ENTRY_TERMS.each do |_month, term_name|
        term_date = SolarTermsData.term_date(date.year, term_name)
        return term_date if term_date > date
      end
      # 올해 없으면 내년 소한
      SolarTermsData.term_date(date.year + 1, "소한")
    end

    # 이전 절기 날짜 찾기
    def self.find_prev_term(date)
      latest = nil
      SolarTermsData::MONTH_ENTRY_TERMS.each do |_month, term_name|
        term_date = SolarTermsData.term_date(date.year, term_name)
        if term_date <= date
          latest = term_date if latest.nil? || term_date > latest
        end
      end
      latest || SolarTermsData.term_date(date.year - 1, "대설")
    end

    # 현재 대운 찾기
    def self.find_current_fortune(fortunes, birth_date)
      current_age = Date.today.year - birth_date.year
      fortunes.find { |f| current_age >= f[:age_start] && current_age <= f[:age_end] }
    end

    # 대운 설명 생성
    def self.fortune_description(stem, branch, element)
      element_desc = {
        "목" => "성장과 발전의 시기. 새로운 시작과 학업에 유리합니다.",
        "화" => "열정과 활력의 시기. 사업 확장과 인맥 형성에 좋습니다.",
        "토" => "안정과 축적의 시기. 부동산과 기반 다지기에 적합합니다.",
        "금" => "결실과 성취의 시기. 재물운과 직장운이 상승합니다.",
        "수" => "지혜와 변화의 시기. 학문과 연구, 해외 활동에 유리합니다."
      }

      branch_animal = EarthlyBranches.animal(branch)
      "#{stem}#{branch}(#{branch_animal}) 대운 — #{element}(#{element_desc[element] || '균형의 시기입니다.'})"
    end
  end
end
