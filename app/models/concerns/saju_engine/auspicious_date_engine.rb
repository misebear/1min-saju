# frozen_string_literal: true

module SajuEngine
  module AuspiciousDateEngine
    # 목적별 길일 조건
    PURPOSE_CONFIG = {
      "이사" => {
        emoji: "🏠",
        label: "이사",
        good_branches: %w[인 묘 진 사 오 미], # 봄·여름 기운 — 새 시작에 좋음
        bad_branches: %w[축 술], # 파·충 기운
        advice: "이사할 때는 맑은 날, 양(陽)의 기운이 강한 날이 좋아요!"
      },
      "결혼" => {
        emoji: "💒",
        label: "결혼",
        good_branches: %w[사 오 미 인 묘], # 화·목 기운 — 열정과 성장
        bad_branches: %w[해 자], # 수 기운 과다 — 눈물·이별 연상
        advice: "결혼식은 음양이 조화로운 날이 최고에요! 서로의 사주도 참고하세요."
      },
      "개업" => {
        emoji: "🏪",
        label: "개업·사업",
        good_branches: %w[인 사 신], # 역마·활동 기운
        bad_branches: %w[술 해], # 공망
        advice: "개업은 활발한 기운이 있는 날이 좋아요! 재물운도 함께 확인하세요."
      },
      "계약" => {
        emoji: "📝",
        label: "계약·거래",
        good_branches: %w[자 축 진 미], # 안정·신뢰의 기운
        bad_branches: %w[묘 유], # 충의 기운
        advice: "중요한 계약이나 거래는 안정적인 기운의 날이 좋아요!"
      },
      "여행" => {
        emoji: "✈️",
        label: "여행",
        good_branches: %w[인 사 신 해], # 역마살 — 이동에 좋음
        bad_branches: %w[축 미 술 진], # 고집·정체의 기운
        advice: "여행은 역마 기운이 있는 날이 최적이에요! 활동적인 에너지!"
      }
    }.freeze

    STEMS = %w[갑 을 병 정 무 기 경 신 임 계].freeze
    BRANCHES = %w[자 축 인 묘 진 사 오 미 신 유 술 해].freeze

    # 천간합 (합이 되는 쌍)
    STEM_HARMONY = {
      "갑" => "기", "을" => "경", "병" => "신", "정" => "임", "무" => "계",
      "기" => "갑", "경" => "을", "신" => "병", "임" => "정", "계" => "무"
    }.freeze

    # 지지충 (충돌하는 쌍)
    BRANCH_CLASH = {
      "자" => "오", "축" => "미", "인" => "신", "묘" => "유", "진" => "술", "사" => "해",
      "오" => "자", "미" => "축", "신" => "인", "유" => "묘", "술" => "진", "해" => "사"
    }.freeze

    # 택일 분석
    def self.find_dates(purpose, start_date, end_date, user_birth_date = nil, user_birth_hour = 0)
      config = PURPOSE_CONFIG[purpose]
      return [] unless config

      # 사용자 일간 구하기 (있으면)
      user_day_stem = nil
      if user_birth_date
        pillars = SajuEngine::PillarCalculator.calculate(user_birth_date, user_birth_hour)
        user_day_stem = pillars[:day][:stem]
      end

      results = []
      (start_date..end_date).each do |date|
        stem_index = date.jd % 10
        branch_index = date.jd % 12
        day_stem = STEMS[stem_index]
        day_branch = BRANCHES[branch_index]

        score = 50 # 기본 점수
        reasons = []

        # 1. 좋은 지지
        if config[:good_branches].include?(day_branch)
          score += 20
          reasons << "#{day_branch}(#{branch_animal(day_branch)}) — #{purpose}에 길한 지지"
        end

        # 2. 나쁜 지지
        if config[:bad_branches].include?(day_branch)
          score -= 20
          reasons << "#{day_branch}(#{branch_animal(day_branch)}) — #{purpose}에 불리한 지지"
        end

        # 3. 천간합 (사용자 일간과 합)
        if user_day_stem && STEM_HARMONY[user_day_stem] == day_stem
          score += 15
          reasons << "#{day_stem}#{day_branch}일 — 본인 일간(#{user_day_stem})과 천간합!"
        end

        # 4. 지지충 확인 (사용자 일지와 충이면 불리)
        if user_birth_date
          pillars = SajuEngine::PillarCalculator.calculate(user_birth_date, user_birth_hour)
          user_day_branch = pillars[:day][:branch]
          if BRANCH_CLASH[user_day_branch] == day_branch
            score -= 15
            reasons << "#{day_branch}일 — 본인 일지(#{user_day_branch})와 충!"
          end
        end

        # 5. 주말 보너스 (실용적)
        if date.saturday? || date.sunday?
          score += 5
          reasons << "주말 — 실행에 유리"
        end

        # 점수 범위 제한
        score = [ [ score, 100 ].min, 10 ].max

        grade = case score
        when 80..100 then "대길"
        when 65..79 then "길"
        when 50..64 then "보통"
        when 35..49 then "흉"
        else "대흉"
        end

        results << {
          date: date,
          day_stem: day_stem,
          day_branch: day_branch,
          score: score,
          grade: grade,
          reasons: reasons,
          weekday: weekday_name(date)
        }
      end

      # 점수순 정렬
      results.sort_by { |r| -r[:score] }
    end

    # 최적 날짜 5개
    def self.best_dates(purpose, start_date, end_date, user_birth_date = nil, user_birth_hour = 0)
      find_dates(purpose, start_date, end_date, user_birth_date, user_birth_hour).first(5)
    end

    private

    def self.branch_animal(branch)
      animals = {
        "자" => "쥐", "축" => "소", "인" => "호랑이", "묘" => "토끼",
        "진" => "용", "사" => "뱀", "오" => "말", "미" => "양",
        "신" => "원숭이", "유" => "닭", "술" => "개", "해" => "돼지"
      }
      animals[branch] || branch
    end

    def self.weekday_name(date)
      %w[일 월 화 수 목 금 토][date.wday]
    end
  end
end
