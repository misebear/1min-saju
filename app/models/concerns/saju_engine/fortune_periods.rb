# frozen_string_literal: true

module SajuEngine
  module FortunePeriods
    # 대운 계산 (10년 주기)
    def self.calculate_major_fortune(saju_result, gender, birth_date)
      day_stem = saju_result[:day][:stem]
      month_stem_idx = saju_result[:month][:stem_index]
      month_branch_idx = saju_result[:month][:branch_index]

      # 양남음녀: 순행, 음남양녀: 역행
      day_yinyang = HeavenlyStems.yinyang(saju_result[:year][:stem])
      forward = (day_yinyang == "양" && gender == "남") || (day_yinyang == "음" && gender == "여")

      fortunes = []
      10.times do |i|
        offset = forward ? (i + 1) : -(i + 1)
        stem_idx = (month_stem_idx + offset) % 10
        branch_idx = (month_branch_idx + offset) % 12

        stem = HeavenlyStems.from_index(stem_idx)
        branch = EarthlyBranches.from_index(branch_idx)

        start_age = (i + 1) * 10
        end_age = start_age + 9

        fortunes << {
          stem: stem,
          branch: branch,
          element: HeavenlyStems.element(stem),
          ten_god: TenGods.determine(day_stem, stem),
          start_age: start_age,
          end_age: end_age,
          start_year: birth_date.year + start_age,
          end_year: birth_date.year + end_age,
          label: "#{stem}#{branch}"
        }
      end

      fortunes
    end

    # 세운 (연간 운세)
    def self.calculate_yearly_fortune(year, day_stem)
      stem_index = (year - 4) % 10
      branch_index = (year - 4) % 12

      stem = HeavenlyStems.from_index(stem_index)
      branch = EarthlyBranches.from_index(branch_index)

      {
        year: year,
        stem: stem,
        branch: branch,
        element: HeavenlyStems.element(stem),
        ten_god: TenGods.determine(day_stem, stem),
        animal: EarthlyBranches.animal(branch),
        label: "#{stem}#{branch} (#{EarthlyBranches.animal(branch)}띠 해)"
      }
    end

    # 월운 (월간 운세)
    def self.calculate_monthly_fortune(year, month, day_stem)
      # 년간에 따른 월간 결정
      year_stem_index = (year - 4) % 10
      year_stem = HeavenlyStems.from_index(year_stem_index)

      date = Date.new(year, month, 15)
      saju_month = PillarCalculator.determine_saju_month(date)

      month_stem_start = PillarCalculator::YEAR_STEM_TO_MONTH_STEM_START[year_stem_index]
      month_stem_index = (month_stem_start + saju_month - 1) % 10
      month_branch_index = (saju_month + 1) % 12

      stem = HeavenlyStems.from_index(month_stem_index)
      branch = EarthlyBranches.from_index(month_branch_index)

      {
        year: year,
        month: month,
        stem: stem,
        branch: branch,
        element: HeavenlyStems.element(stem),
        ten_god: TenGods.determine(day_stem, stem),
        label: "#{year}년 #{month}월 (#{stem}#{branch})"
      }
    end

    # 오늘의 운세 데이터
    def self.calculate_daily_fortune(date, day_stem)
      today_pillar = PillarCalculator.calculate_day_pillar(date)
      ten_god = TenGods.determine(day_stem, today_pillar[:stem])

      # 운세 점수 계산 (십성 기반)
      score = calculate_fortune_score(ten_god, today_pillar[:element], HeavenlyStems.element(day_stem))

      # 행운 아이템
      lucky = calculate_lucky_items(today_pillar, day_stem)

      {
        date: date,
        stem: today_pillar[:stem],
        branch: today_pillar[:branch],
        element: today_pillar[:element],
        ten_god: ten_god,
        score: score,
        lucky: lucky,
        label: "#{today_pillar[:stem]}#{today_pillar[:branch]}일"
      }
    end

    private

    def self.calculate_fortune_score(ten_god, day_element, my_element)
      base_scores = {
        "정관" => 85, "정인" => 82, "정재" => 80, "식신" => 78,
        "편인" => 72, "편재" => 70, "비견" => 68, "겁재" => 65,
        "상관" => 60, "편관" => 58
      }
      base = base_scores[ten_god] || 70
      # 약간의 변동 추가
      variation = (Date.today.day * 3 + Date.today.month * 7) % 15
      [ base + variation - 7, 100 ].min.clamp(40, 98)
    end

    def self.calculate_lucky_items(today_pillar, day_stem)
      element = today_pillar[:element]
      colors = {
        "목" => "초록색", "화" => "빨간색", "토" => "노란색",
        "금" => "흰색", "수" => "파란색"
      }
      directions = {
        "목" => "동쪽", "화" => "남쪽", "토" => "중앙",
        "금" => "서쪽", "수" => "북쪽"
      }
      numbers = {
        "목" => "3, 8", "화" => "2, 7", "토" => "5, 10",
        "금" => "4, 9", "수" => "1, 6"
      }

      {
        color: colors[element] || "보라색",
        direction: directions[element] || "중앙",
        number: numbers[element] || "5",
        element_emoji: FiveElements::ELEMENT_EMOJIS[element]
      }
    end
  end
end
