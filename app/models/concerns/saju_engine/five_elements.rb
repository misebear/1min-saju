# frozen_string_literal: true

module SajuEngine
  module FiveElements
    ELEMENTS = %w[목 화 토 금 수].freeze
    ELEMENT_NAMES = {
      "목" => "나무", "화" => "불", "토" => "흙",
      "금" => "쇠", "수" => "물"
    }.freeze

    ELEMENT_EMOJIS = {
      "목" => "🌳", "화" => "🔥", "토" => "⛰️",
      "금" => "⚔️", "수" => "💧"
    }.freeze

    ELEMENT_COLORS = {
      "목" => "#4CAF50", "화" => "#F44336", "토" => "#FFC107",
      "금" => "#E0E0E0", "수" => "#2196F3"
    }.freeze

    ELEMENT_CSS_COLORS = {
      "목" => "var(--element-wood)", "화" => "var(--element-fire)",
      "토" => "var(--element-earth)", "금" => "var(--element-metal)",
      "수" => "var(--element-water)"
    }.freeze

    # 상생 관계 (서로 돕는 관계)
    GENERATING = {
      "목" => "화", "화" => "토", "토" => "금",
      "금" => "수", "수" => "목"
    }.freeze

    # 상극 관계 (서로 이기는 관계)
    OVERCOMING = {
      "목" => "토", "토" => "수", "수" => "화",
      "화" => "금", "금" => "목"
    }.freeze

    # 오행 분포 분석
    def self.analyze_distribution(pillars)
      distribution = { "목" => 0, "화" => 0, "토" => 0, "금" => 0, "수" => 0 }

      pillars.each do |pillar|
        stem_element = HeavenlyStems.element(pillar[:stem])
        branch_element = EarthlyBranches.element(pillar[:branch])
        distribution[stem_element] += 1 if stem_element
        distribution[branch_element] += 1 if branch_element
      end

      distribution
    end

    # 과다/부족 오행 판별
    def self.analyze_balance(distribution)
      total = distribution.values.sum.to_f
      return {} if total.zero?

      result = {}
      distribution.each do |element, count|
        ratio = (count / total * 100).round(1)
        status = if ratio >= 37.5
                   "과다"
        elsif ratio >= 25.0
                   "강함"
        elsif ratio >= 12.5
                   "보통"
        elsif ratio > 0
                   "약함"
        else
                   "없음"
        end
        result[element] = { count: count, ratio: ratio, status: status }
      end
      result
    end

    # 용신 (필요한 오행) 추정
    def self.estimate_yongshin(distribution)
      # 가장 부족한 오행을 용신으로 추정
      min_element = distribution.min_by { |_, v| v }
      elem = min_element[0]
      name = ELEMENT_NAMES[elem]

      reasons = {
        "목" => "나무(목)의 기운이 부족해요! 🌿 초록색 옷이나 소품을 가까이하고, 산책이나 식물 키우기가 운기 충전에 도움이 돼요.",
        "화" => "불(화)의 기운이 부족해요! 🔥 빨간색이나 주황색 아이템을 활용하고, 햇빛을 자주 쬐는 게 좋아요.",
        "토" => "흙(토)의 기운이 부족해요! 🪨 노란색·갈색 계열을 가까이하고, 규칙적인 생활 루틴을 만들면 운기가 올라가요.",
        "금" => "쇠(금)의 기운이 부족해요! 🪙 흰색·은색 아이템을 활용하고, 정돈된 환경을 유지하면 에너지가 보충돼요.",
        "수" => "물(수)의 기운이 부족해요! 💧 검정색·파란색 계열을 활용하고, 물이 있는 곳(바다, 호수)을 방문하면 좋아요."
      }

      {
        element: elem,
        name: name,
        emoji: ELEMENT_EMOJIS[elem],
        reason: reasons[elem] || "#{name}의 기운이 부족하여 보충이 필요해요!"
      }
    end

    # 상생 여부
    def self.generates?(from, to)
      GENERATING[from] == to
    end

    # 상극 여부
    def self.overcomes?(from, to)
      OVERCOMING[from] == to
    end
  end
end
