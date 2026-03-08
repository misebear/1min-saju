# frozen_string_literal: true

module SajuEngine
  module MbtiMapper
    # MBTI 4축을 사주 오행·음양·십성에서 추론
    #
    # 반환 예시:
    # {
    #   type: "ENFP",
    #   axes: {
    #     ei: { label: "E", score: 65, desc: "양간(甲) + 화·목 에너지가 활발" },
    #     sn: { label: "N", score: 70, desc: "수·목 비중이 높아 직관적" },
    #     tf: { label: "F", score: 55, desc: "식신·정재 기운으로 감성적" },
    #     jp: { label: "P", score: 60, desc: "수·화 기운으로 자유로운 스타일" }
    #   },
    #   description: "...",
    #   best_match: ["INTJ", "INFJ"],
    #   saju_insight: "..."
    # }
    def self.analyze(saju, ten_gods)
      day_stem = saju[:day][:stem]
      element = HeavenlyStems.element(day_stem)
      yinyang = HeavenlyStems.yinyang(day_stem)
      dist = saju[:distribution] || {}

      # 오행 비율 계산
      total = dist.values.sum.to_f
      total = 1.0 if total <= 0
      ratios = {}
      dist.each { |k, v| ratios[k] = (v / total * 100).round }

      # === E/I 축 ===
      ei_score = calculate_ei(yinyang, element, ratios)

      # === S/N 축 ===
      sn_score = calculate_sn(element, ratios)

      # === T/F 축 ===
      tf_score = calculate_tf(ten_gods)

      # === J/P 축 ===
      jp_score = calculate_jp(element, ratios, yinyang)

      # MBTI 타입 조합
      e_label = ei_score >= 50 ? "E" : "I"
      s_label = sn_score >= 50 ? "S" : "N"
      t_label = tf_score >= 50 ? "T" : "F"
      j_label = jp_score >= 50 ? "J" : "P"
      mbti_type = "#{e_label}#{s_label}#{t_label}#{j_label}"

      {
        type: mbti_type,
        axes: {
          ei: { label: e_label, score: ei_score,
                other_label: e_label == "E" ? "I" : "E",
                other_score: 100 - ei_score,
                desc: ei_desc(yinyang, element, ratios) },
          sn: { label: s_label, score: sn_score,
                other_label: s_label == "S" ? "N" : "S",
                other_score: 100 - sn_score,
                desc: sn_desc(element, ratios) },
          tf: { label: t_label, score: tf_score,
                other_label: t_label == "T" ? "F" : "T",
                other_score: 100 - tf_score,
                desc: tf_desc(ten_gods) },
          jp: { label: j_label, score: jp_score,
                other_label: j_label == "J" ? "P" : "P",
                other_score: 100 - jp_score,
                desc: jp_desc(element, yinyang) }
        },
        description: MBTI_DESCRIPTIONS[mbti_type] || "독특한 매력의 소유자!",
        best_match: MBTI_MATCHES[mbti_type] || [],
        saju_insight: generate_insight(mbti_type, element, yinyang),
        emoji: MBTI_EMOJIS[mbti_type] || "🧬"
      }
    end

    private

    # ──── E/I 판정 ────
    def self.calculate_ei(yinyang, element, ratios)
      score = 50
      # 양간 → E 경향 (+15)
      score += (yinyang == "양" ? 15 : -15)
      # 화·목 많으면 E (+), 수·금 많으면 I (+)
      fire_wood = (ratios["화"] || 0) + (ratios["목"] || 0)
      water_metal = (ratios["수"] || 0) + (ratios["금"] || 0)
      score += ((fire_wood - water_metal) * 0.3).round
      # 일간 오행 보정
      case element
      when "화" then score += 8
      when "목" then score += 5
      when "수" then score -= 8
      when "금" then score -= 5
      end
      score.clamp(15, 85)
    end

    def self.ei_desc(yinyang, element, ratios)
      if yinyang == "양"
        "#{element == '화' ? '태양' : '양간'}의 활발한 기운 + #{element} 에너지"
      else
        "#{element == '수' ? '깊은 물' : '음간'}의 내면 세계 + #{element} 에너지"
      end
    end

    # ──── S/N 판정 ────
    def self.calculate_sn(element, ratios)
      score = 50
      # 토·금 높으면 S (현실적·실용적)
      earth_metal = (ratios["토"] || 0) + (ratios["금"] || 0)
      # 수·목 높으면 N (직관적·이상적)
      water_wood = (ratios["수"] || 0) + (ratios["목"] || 0)
      score += ((earth_metal - water_wood) * 0.3).round
      # 일간 오행 보정
      case element
      when "토" then score += 10
      when "금" then score += 6
      when "수" then score -= 10
      when "목" then score -= 6
      end
      score.clamp(15, 85)
    end

    def self.sn_desc(element, ratios)
      earth_metal = (ratios["토"] || 0) + (ratios["금"] || 0)
      water_wood = (ratios["수"] || 0) + (ratios["목"] || 0)
      if earth_metal >= water_wood
        "토·금 에너지가 강해 현실적이고 실용적"
      else
        "수·목 에너지가 강해 직관적이고 창의적"
      end
    end

    # ──── T/F 판정 ────
    def self.calculate_tf(ten_gods)
      score = 50
      # 십성에서 T/F 판정
      thinking_gods = [ "편관", "편인", "상관", "겁재" ]
      feeling_gods = [ "정관", "정인", "식신", "정재" ]

      gods_list = [ ten_gods[:year_stem], ten_gods[:month_stem],
                   ten_gods[:hour_stem], ten_gods[:year_branch],
                   ten_gods[:month_branch], ten_gods[:hour_branch] ].compact

      t_count = gods_list.count { |g| thinking_gods.include?(g) }
      f_count = gods_list.count { |g| feeling_gods.include?(g) }

      diff = t_count - f_count
      score += (diff * 12).clamp(-30, 30)
      score.clamp(15, 85)
    end

    def self.tf_desc(ten_gods)
      thinking_gods = [ "편관", "편인", "상관", "겁재" ]
      feeling_gods = [ "정관", "정인", "식신", "정재" ]
      gods_list = [ ten_gods[:year_stem], ten_gods[:month_stem], ten_gods[:hour_stem] ].compact
      t_count = gods_list.count { |g| thinking_gods.include?(g) }
      f_count = gods_list.count { |g| feeling_gods.include?(g) }
      if t_count >= f_count
        "편관·편인 등 분석적 십성이 강함"
      else
        "정인·식신 등 공감적 십성이 강함"
      end
    end

    # ──── J/P 판정 ────
    def self.calculate_jp(element, ratios, yinyang)
      score = 50
      # 금·토 → J (규칙·체계)
      case element
      when "금" then score += 12
      when "토" then score += 8
      when "수" then score -= 10
      when "화" then score -= 8
      when "목" then score -= 3
      end
      # 양간 → J 경향, 음간 → P 경향
      score += (yinyang == "양" ? 5 : -5)
      # 오행 분포
      structured = (ratios["금"] || 0) + (ratios["토"] || 0)
      flexible = (ratios["수"] || 0) + (ratios["화"] || 0)
      score += ((structured - flexible) * 0.2).round
      score.clamp(15, 85)
    end

    def self.jp_desc(element, yinyang)
      case element
      when "금", "토"
        "#{element} 기운의 체계적이고 계획적인 성향"
      when "수", "화"
        "#{element} 기운의 유연하고 자유로운 성향"
      else
        "목 기운의 성장 지향적 성향"
      end
    end

    # ──── 사주 인사이트 ────
    def self.generate_insight(mbti_type, element, yinyang)
      element_name = { "목" => "나무", "화" => "불", "토" => "흙", "금" => "쇠", "수" => "물" }
      nature = yinyang == "양" ? "활력" : "섬세함"
      "#{element_name[element]}의 #{nature}을 가진 #{mbti_type} 타입이에요! " \
      "사주의 오행 에너지가 당신의 MBTI 성향을 독특하게 만들어줘요. " \
      "서양 심리학과 동양 명리학이 만나 더 깊은 자아 이해가 가능합니다 ✨"
    end

    # ──── MBTI 16유형 설명 (Z세대 톤) ────
    MBTI_DESCRIPTIONS = {
      "INTJ" => "전략적 마스터플래너! 🧠 사주의 금·수 에너지가 강해 논리적이고 미래를 내다보는 비전이 있어요. 혼자만의 시간에 최고의 아이디어가 떠오르는 타입!",
      "INTP" => "호기심 폭발 분석러! 🔬 수 에너지의 깊은 사고력으로 세상의 원리를 파헤치는 걸 좋아해요. 머릿속이 항상 돌아가는 아이디어 뱅크!",
      "ENTJ" => "타고난 리더 CEO형! 👑 양간의 강한 추진력과 금 에너지의 결단력이 만나 어디서든 중심이 되는 타입이에요!",
      "ENTP" => "번뜩이는 발명가! ⚡ 양간의 에너지와 수·목의 창의력이 합쳐져 새로운 가능성을 계속 탐험하는 타입!",
      "INFJ" => "깊은 공감러 예언자! 🔮 음간의 섬세함과 수 에너지의 직관이 만나 사람의 마음을 꿰뚫어보는 타입이에요!",
      "INFP" => "낭만적 몽상가! 🌈 목 에너지의 성장 욕구와 음간의 감성이 어우러져 이상적인 세계를 꿈꾸는 아티스트 기질!",
      "ENFJ" => "따뜻한 인플루언서! 🤗 양간의 활발함과 화 에너지의 열정으로 사람들을 이끌고 영감을 주는 타입!",
      "ENFP" => "자유로운 영혼! 🦋 화·목 에너지가 풍부해 어디서든 분위기를 밝히고 새로운 경험을 추구하는 열정파!",
      "ISTJ" => "믿음직한 관리자! 📋 토·금 에너지의 안정감으로 맡은 일을 끝까지 책임지는 신뢰의 아이콘!",
      "ISFJ" => "든든한 수호천사! 🛡️ 토 에너지의 포용력과 음간의 세심함으로 주변을 따뜻하게 감싸는 타입!",
      "ESTJ" => "실행력 만렙 리더! 💪 양간의 추진력과 토·금 에너지로 조직을 체계적으로 이끄는 실전형!",
      "ESFJ" => "사교적인 어울림왕! 🎉 양간의 사교성과 화·토 에너지로 모임의 분위기 메이커 역할!",
      "ISTP" => "쿨한 장인! 🔧 금 에너지의 정밀함과 음간의 독립성으로 문제를 논리적으로 해결하는 프로!",
      "ISFP" => "감성 아티스트! 🎨 목 에너지의 예술성과 음간의 섬세한 감각이 빛나는 자유로운 영혼!",
      "ESTP" => "액션 히어로! 🔥 양간의 폭발적 에너지와 화·금의 결합으로 지금 이 순간을 즐기는 모험가!",
      "ESFP" => "무대 위의 스타! ⭐ 화 에너지의 화려함과 양간의 사교성으로 어디서든 주인공인 엔터테이너!"
    }.freeze

    # ──── 궁합 잘 맞는 MBTI ────
    MBTI_MATCHES = {
      "INTJ" => [ "ENFP", "ENTP" ], "INTP" => [ "ENTJ", "ENFJ" ],
      "ENTJ" => [ "INTP", "INFP" ], "ENTP" => [ "INTJ", "INFJ" ],
      "INFJ" => [ "ENTP", "ENFP" ], "INFP" => [ "ENTJ", "ENFJ" ],
      "ENFJ" => [ "INTP", "INFP" ], "ENFP" => [ "INTJ", "INFJ" ],
      "ISTJ" => [ "ESFP", "ESTP" ], "ISFJ" => [ "ESTP", "ESFP" ],
      "ESTJ" => [ "ISFP", "ISTP" ], "ESFJ" => [ "ISTP", "ISFP" ],
      "ISTP" => [ "ESFJ", "ESTJ" ], "ISFP" => [ "ESTJ", "ESFJ" ],
      "ESTP" => [ "ISFJ", "ISTJ" ], "ESFP" => [ "ISTJ", "ISFJ" ]
    }.freeze

    # ──── MBTI 이모지 ────
    MBTI_EMOJIS = {
      "INTJ" => "🧠", "INTP" => "🔬", "ENTJ" => "👑", "ENTP" => "⚡",
      "INFJ" => "🔮", "INFP" => "🌈", "ENFJ" => "🤗", "ENFP" => "🦋",
      "ISTJ" => "📋", "ISFJ" => "🛡️", "ESTJ" => "💪", "ESFJ" => "🎉",
      "ISTP" => "🔧", "ISFP" => "🎨", "ESTP" => "🔥", "ESFP" => "⭐"
    }.freeze
  end
end
