# frozen_string_literal: true

module SajuEngine
  module SpecialStars
    # 주요 신살 정의
    STARS = {
      "역마" => { meaning: "변화와 이동의 별", effect: "해외운, 이사, 출장이 많음", emoji: "🏇" },
      "도화" => { meaning: "매력과 인기의 별", effect: "이성에게 인기, 예술적 재능", emoji: "🌸" },
      "화개" => { meaning: "학문과 예술의 별", effect: "종교, 철학, 예술에 관심", emoji: "🎨" },
      "천을귀인" => { meaning: "가장 큰 귀인의 별", effect: "어려울 때 귀인이 나타남", emoji: "👼" },
      "문창귀인" => { meaning: "학문의 귀인", effect: "공부, 시험운 좋음", emoji: "📖" },
      "천덕귀인" => { meaning: "하늘의 덕", effect: "재난을 피하는 힘", emoji: "🌟" },
      "월덕귀인" => { meaning: "달의 덕", effect: "부드러운 성품, 인덕", emoji: "🌙" },
      "양인" => { meaning: "날카로운 칼날", effect: "결단력 강함, 과격함 주의", emoji: "⚔️" },
      "공망" => { meaning: "빈 공간", effect: "해당 분야에서 허전함", emoji: "🕳️" },
      "삼합" => { meaning: "세 가지가 합", effect: "대인관계 좋음", emoji: "🤝" }
    }.freeze

    # 역마 판별 (일지 기준)
    YOKMA_MAP = {
      "자" => "인", "축" => "해", "인" => "신", "묘" => "사",
      "진" => "인", "사" => "해", "오" => "신", "미" => "사",
      "신" => "인", "유" => "해", "술" => "신", "해" => "사"
    }.freeze

    # 도화 판별 (일지 기준)
    DOHWA_MAP = {
      "자" => "유", "축" => "오", "인" => "묘", "묘" => "자",
      "진" => "유", "사" => "오", "오" => "묘", "미" => "자",
      "신" => "유", "유" => "오", "술" => "묘", "해" => "자"
    }.freeze

    # 화개 판별 (일지 기준)
    HWAGAE_MAP = {
      "자" => "진", "축" => "축", "인" => "술", "묘" => "미",
      "진" => "진", "사" => "축", "오" => "술", "미" => "미",
      "신" => "진", "유" => "축", "술" => "술", "해" => "미"
    }.freeze

    # 천을귀인 판별 (일간 기준)
    CHEONUL_MAP = {
      "갑" => %w[축 미], "을" => %w[자 신], "병" => %w[해 유],
      "정" => %w[해 유], "무" => %w[축 미], "기" => %w[자 신],
      "경" => %w[축 미], "신" => %w[인 오], "임" => %w[묘 사],
      "계" => %w[묘 사]
    }.freeze

    # 사주에 존재하는 신살 분석
    def self.analyze(saju_result)
      day_branch = saju_result[:day][:branch]
      day_stem = saju_result[:day][:stem]
      all_branches = saju_result[:pillars].map { |p| p[:branch] }

      stars = []

      # 역마 검사
      yokma_branch = YOKMA_MAP[day_branch]
      if all_branches.include?(yokma_branch)
        stars << { name: "역마", **STARS["역마"] }
      end

      # 도화 검사
      dohwa_branch = DOHWA_MAP[day_branch]
      if all_branches.include?(dohwa_branch)
        stars << { name: "도화", **STARS["도화"] }
      end

      # 화개 검사
      hwagae_branch = HWAGAE_MAP[day_branch]
      if all_branches.include?(hwagae_branch)
        stars << { name: "화개", **STARS["화개"] }
      end

      # 천을귀인 검사
      cheonul_branches = CHEONUL_MAP[day_stem] || []
      if (all_branches & cheonul_branches).any?
        stars << { name: "천을귀인", **STARS["천을귀인"] }
      end

      stars
    end
  end
end
