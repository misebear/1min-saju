# frozen_string_literal: true

module SajuEngine
  module PillarCalculator
    # 60갑자 기준일 (1900-01-01 = 경자일)
    BASE_DATE = Date.new(1900, 1, 1)
    BASE_DAY_STEM_INDEX = 6   # 경(庚) = index 6
    BASE_DAY_BRANCH_INDEX = 0 # 자(子) = index 0

    # 24절기 데이터 (양력 기준 근사값)
    # 월주 결정을 위한 절기 시작일 (절입일)
    SOLAR_TERMS = {
      1  => { name: "입춘", month: 2, day: 4 },   # 인월 시작
      2  => { name: "경칩", month: 3, day: 6 },   # 묘월 시작
      3  => { name: "청명", month: 4, day: 5 },   # 진월 시작
      4  => { name: "입하", month: 5, day: 6 },   # 사월 시작
      5  => { name: "망종", month: 6, day: 6 },   # 오월 시작
      6  => { name: "소서", month: 7, day: 7 },   # 미월 시작
      7  => { name: "입추", month: 8, day: 7 },   # 신월 시작
      8  => { name: "백로", month: 9, day: 8 },   # 유월 시작
      9  => { name: "한로", month: 10, day: 8 },  # 술월 시작
      10 => { name: "입동", month: 11, day: 7 },  # 해월 시작
      11 => { name: "대설", month: 12, day: 7 },  # 자월 시작
      12 => { name: "소한", month: 1, day: 6 }    # 축월 시작
    }.freeze

    # 년간에 따른 월간 시작 인덱스 (년간합표)
    # 갑/기년 → 병인월, 을/경년 → 무인월, 병/신년 → 경인월, 정/임년 → 임인월, 무/계년 → 갑인월
    YEAR_STEM_TO_MONTH_STEM_START = {
      0 => 2, 5 => 2,   # 갑/기 → 병(2)
      1 => 4, 6 => 4,   # 을/경 → 무(4)
      2 => 6, 7 => 6,   # 병/신 → 경(6)
      3 => 8, 8 => 8,   # 정/임 → 임(8)
      4 => 0, 9 => 0    # 무/계 → 갑(0)
    }.freeze

    # 일간에 따른 시간 시작 인덱스 (일간합표)
    DAY_STEM_TO_HOUR_STEM_START = {
      0 => 0, 5 => 0,   # 갑/기일 → 갑자시
      1 => 2, 6 => 2,   # 을/경일 → 병자시
      2 => 4, 7 => 4,   # 병/신일 → 무자시
      3 => 6, 8 => 6,   # 정/임일 → 경자시
      4 => 8, 9 => 8    # 무/계일 → 임자시
    }.freeze

    # 사주팔자 전체 계산
    def self.calculate(birth_date, birth_hour, gender = "남")
      year_pillar = calculate_year_pillar(birth_date)
      month_pillar = calculate_month_pillar(birth_date, year_pillar[:stem])
      day_pillar = calculate_day_pillar(birth_date)
      hour_pillar = calculate_hour_pillar(birth_hour, day_pillar[:stem])

      pillars = [ year_pillar, month_pillar, day_pillar, hour_pillar ]
      distribution = FiveElements.analyze_distribution(pillars)
      balance = FiveElements.analyze_balance(distribution)
      yongshin = FiveElements.estimate_yongshin(distribution)

      {
        year: year_pillar,
        month: month_pillar,
        day: day_pillar,
        hour: hour_pillar,
        pillars: pillars,
        distribution: distribution,
        balance: balance,
        yongshin: yongshin,
        day_master: day_pillar[:stem],  # 일간 = 본인
        gender: gender,
        zodiac: EarthlyBranches.animal(year_pillar[:branch]),
        zodiac_emoji: EarthlyBranches::BRANCH_EMOJIS[year_pillar[:branch]]
      }
    end

    # 년주 계산
    def self.calculate_year_pillar(date)
      # 입춘(2/4) 이전이면 전년도 간지 사용
      year = date.year
      year -= 1 if date.month < 2 || (date.month == 2 && date.day < 4)

      stem_index = (year - 4) % 10
      branch_index = (year - 4) % 12

      {
        stem: HeavenlyStems.from_index(stem_index),
        branch: EarthlyBranches.from_index(branch_index),
        stem_index: stem_index,
        branch_index: branch_index,
        element: HeavenlyStems.element(HeavenlyStems.from_index(stem_index)),
        yinyang: HeavenlyStems.yinyang(HeavenlyStems.from_index(stem_index))
      }
    end

    # 월주 계산 (절기 기준)
    def self.calculate_month_pillar(date, year_stem)
      # 절기 기반 월 결정
      saju_month = determine_saju_month(date)

      # 년간에 따른 월간 결정
      year_stem_idx = HeavenlyStems.index(year_stem)
      month_stem_start = YEAR_STEM_TO_MONTH_STEM_START[year_stem_idx]
      month_stem_index = (month_stem_start + saju_month - 1) % 10

      # 월지는 인(寅)월부터 시작
      month_branch_index = (saju_month + 1) % 12

      stem = HeavenlyStems.from_index(month_stem_index)
      branch = EarthlyBranches.from_index(month_branch_index)

      {
        stem: stem,
        branch: branch,
        stem_index: month_stem_index,
        branch_index: month_branch_index,
        element: HeavenlyStems.element(stem),
        yinyang: HeavenlyStems.yinyang(stem)
      }
    end

    # 일주 계산
    def self.calculate_day_pillar(date)
      days_diff = (date - BASE_DATE).to_i
      stem_index = (BASE_DAY_STEM_INDEX + days_diff) % 10
      branch_index = (BASE_DAY_BRANCH_INDEX + days_diff) % 12

      stem = HeavenlyStems.from_index(stem_index)
      branch = EarthlyBranches.from_index(branch_index)

      {
        stem: stem,
        branch: branch,
        stem_index: stem_index,
        branch_index: branch_index,
        element: HeavenlyStems.element(stem),
        yinyang: HeavenlyStems.yinyang(stem)
      }
    end

    # 시주 계산
    def self.calculate_hour_pillar(hour, day_stem)
      hour_branch = EarthlyBranches.branch_for_hour(hour)
      hour_branch_index = EarthlyBranches.index(hour_branch)

      day_stem_idx = HeavenlyStems.index(day_stem)
      hour_stem_start = DAY_STEM_TO_HOUR_STEM_START[day_stem_idx]
      hour_stem_index = (hour_stem_start + hour_branch_index) % 10

      stem = HeavenlyStems.from_index(hour_stem_index)

      {
        stem: stem,
        branch: hour_branch,
        stem_index: hour_stem_index,
        branch_index: hour_branch_index,
        element: HeavenlyStems.element(stem),
        yinyang: HeavenlyStems.yinyang(stem)
      }
    end

    # 절기 기반 사주 월 결정 (1~12, 1=인월)
    def self.determine_saju_month(date)
      SOLAR_TERMS.each do |month_num, term|
        term_date = Date.new(
          term[:month] <= 2 ? date.year : date.year,
          term[:month],
          term[:day]
        )
        next_month_num = (month_num % 12) + 1
        next_term = SOLAR_TERMS[next_month_num]

        next_year = date.year
        next_year += 1 if next_term[:month] < term[:month]

        next_term_date = Date.new(next_year, next_term[:month], next_term[:day])

        return month_num if date >= term_date && date < next_term_date
      end

      # 기본값: 양력 월 기반 근사
      ((date.month + 10) % 12) + 1
    end
  end
end
