# frozen_string_literal: true

module SajuEngine
  module TenGods
    # 십성 (十星) - 일간과 다른 천간의 관계
    GODS = {
      same_yang: "비견",     # 같은 오행, 같은 음양
      same_yin: "겁재",      # 같은 오행, 다른 음양
      generate_yang: "식신", # 내가 생하는, 같은 음양
      generate_yin: "상관",  # 내가 생하는, 다른 음양
      wealth_yang: "편재",   # 내가 극하는, 같은 음양
      wealth_yin: "정재",    # 내가 극하는, 다른 음양
      power_yang: "편관",    # 나를 극하는, 같은 음양
      power_yin: "정관",     # 나를 극하는, 다른 음양
      seal_yang: "편인",     # 나를 생하는, 같은 음양
      seal_yin: "정인"       # 나를 생하는, 다른 음양
    }.freeze

    GOD_DESCRIPTIONS = {
      "비견" => {
        meaning: "나와 같은 에너지를 가진 별이에요. 독립심과 자존감이 강하고, 스스로의 힘으로 길을 개척하려는 성향이 있어요.",
        keyword: "독립심, 자존심, 동료 의식",
        emoji: "👥",
        tooltip: "비견(比肩) — '어깨를 나란히 한다'는 뜻으로, 나와 같은 기운을 가진 존재를 의미해요"
      },
      "겁재" => {
        meaning: "사교적이고 추진력 있는 별이에요. 사람을 모으고 이끄는 능력이 있지만, 욕심이 과하면 주의가 필요해요.",
        keyword: "사교성, 리더십, 추진력",
        emoji: "🤝",
        tooltip: "겁재(劫財) — '재물을 다투다'는 뜻이지만, 사실은 경쟁을 통해 성장하는 에너지를 뜻해요"
      },
      "식신" => {
        meaning: "재능과 여유로움의 별이에요! 먹는 것도 좋아하고, 창작 활동에 소질이 있어요. 느긋하고 낙천적인 분위기를 가져요.",
        keyword: "재능, 여유, 창작 활동",
        emoji: "🎨",
        tooltip: "식신(食神) — '먹여 살리는 신'이라는 뜻으로, 타고난 재능으로 먹고사는 능력을 의미해요"
      },
      "상관" => {
        meaning: "표현력과 자유로운 영혼의 별이에요! 예술적 감각이 뛰어나고 자기표현을 잘해요. 기존 규칙에 얽매이지 않는 성향이에요.",
        keyword: "자유, 표현력, 창의성",
        emoji: "🎭",
        tooltip: "상관(傷官) — '관직을 해치다'는 다소 무서운 뜻이지만, 실은 기존 틀을 깨는 창조적 에너지를 뜻해요"
      },
      "편재" => {
        meaning: "도전정신과 투자감각의 별이에요! 돈의 흐름을 잘 읽고, 새로운 사업 기회를 포착하는 능력이 있어요.",
        keyword: "도전, 투자, 사업 감각",
        emoji: "💰",
        tooltip: "편재(偏財) — '치우친 재물'이라는 뜻으로, 월급보다는 사업·투자로 돈을 버는 스타일을 뜻해요"
      },
      "정재" => {
        meaning: "안정적인 재물과 성실함의 별이에요! 꾸준히 모으고 계획적으로 관리하는 능력이 뛰어나요.",
        keyword: "성실, 안정, 저축 능력",
        emoji: "🏦",
        tooltip: "정재(正財) — '바른 재물'이라는 뜻으로, 정당한 노력으로 돈을 버는 성실한 스타일이에요"
      },
      "편관" => {
        meaning: "도전과 변화를 이끄는 별이에요! 카리스마가 있고 권력을 다루는 감각이 있어요. 때로는 급격한 변화를 만들기도 해요.",
        keyword: "도전, 카리스마, 변화",
        emoji: "⚡",
        tooltip: "편관(偏官) — '치우친 관직'이라는 뜻으로, 칠살(七殺)이라고도 불려요. 강한 추진력과 카리스마를 의미해요"
      },
      "정관" => {
        meaning: "명예와 질서를 중시하는 별이에요! 직장생활이나 조직 안에서 인정받고 승진하는 에너지가 있어요.",
        keyword: "명예, 직장, 사회적 인정",
        emoji: "👔",
        tooltip: "정관(正官) — '바른 관직'이라는 뜻으로, 정당한 지위와 명예를 얻는 에너지를 의미해요"
      },
      "편인" => {
        meaning: "독특한 학문과 직관의 별이에요! 일반적인 공부보다 특수하거나 창의적인 분야에서 빛을 발해요.",
        keyword: "직관, 창의적 학습, 특수 분야",
        emoji: "📚",
        tooltip: "편인(偏印) — '치우친 도장'이라는 뜻으로, 정통보다는 독자적인 방법을 추구하는 학문 에너지예요"
      },
      "정인" => {
        meaning: "학문과 지혜의 별이에요! 배움을 좋아하고 자격증이나 학위 취득에 유리해요. 어머니의 사랑 같은 따뜻한 에너지이기도 해요.",
        keyword: "학문, 자격증, 지적 호기심",
        emoji: "🎓",
        tooltip: "정인(正印) — '바른 도장'이라는 뜻으로, 학업과 자격, 어머니의 에너지를 의미해요"
      }
    }.freeze

    # 일간 기준으로 특정 천간의 십성 판별
    def self.determine(day_stem, target_stem)
      day_element = HeavenlyStems.element(day_stem)
      target_element = HeavenlyStems.element(target_stem)
      day_yy = HeavenlyStems.yinyang(day_stem)
      target_yy = HeavenlyStems.yinyang(target_stem)
      same_yy = day_yy == target_yy

      if day_element == target_element
        same_yy ? "비견" : "겁재"
      elsif FiveElements.generates?(day_element, target_element)
        same_yy ? "식신" : "상관"
      elsif FiveElements.overcomes?(day_element, target_element)
        same_yy ? "편재" : "정재"
      elsif FiveElements.overcomes?(target_element, day_element)
        same_yy ? "편관" : "정관"
      elsif FiveElements.generates?(target_element, day_element)
        same_yy ? "편인" : "정인"
      end
    end

    # 사주 전체의 십성 분석
    def self.analyze(saju_result)
      day_stem = saju_result[:day][:stem]

      {
        year_stem: determine(day_stem, saju_result[:year][:stem]),
        month_stem: determine(day_stem, saju_result[:month][:stem]),
        hour_stem: determine(day_stem, saju_result[:hour][:stem])
      }
    end
  end
end
