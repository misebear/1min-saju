# frozen_string_literal: true

require_relative "saju_engine/heavenly_stems"
require_relative "saju_engine/earthly_branches"
require_relative "saju_engine/five_elements"
require_relative "saju_engine/pillar_calculator"
require_relative "saju_engine/ten_gods"
require_relative "saju_engine/fortune_periods"
require_relative "saju_engine/special_stars"
require_relative "saju_engine/trends_2026"
require_relative "saju_engine/timezone_correction"
require_relative "saju_engine/chat_engine"
require_relative "saju_engine/solo_destiny"
require_relative "saju_engine/dream_engine"
require_relative "saju_engine/zodiac_engine"
require_relative "saju_engine/auspicious_date_engine"

module SajuEngine
  # 전체 사주 분석 실행
  def self.full_analysis(birth_date, birth_hour, gender = "남")
    saju = PillarCalculator.calculate(birth_date, birth_hour, gender)
    ten_gods = TenGods.analyze(saju)
    special_stars = SpecialStars.analyze(saju)
    major_fortune = FortunePeriods.calculate_major_fortune(saju, gender, birth_date)
    yearly_fortune = FortunePeriods.calculate_yearly_fortune(Date.today.year, saju[:day][:stem])
    daily_fortune = FortunePeriods.calculate_daily_fortune(Date.today, saju[:day][:stem])

    day_element = HeavenlyStems.element(saju[:day][:stem])

    {
      saju: saju,
      ten_gods: ten_gods,
      special_stars: special_stars,
      major_fortune: major_fortune,
      yearly_fortune: yearly_fortune,
      daily_fortune: daily_fortune,
      personality: analyze_personality(saju, ten_gods),
      career: analyze_career(saju, ten_gods),
      love: analyze_love(saju, ten_gods),
      trend_2026: {
        year_info: Trends2026::YEAR_INFO,
        general: Trends2026.element_trend_advice(day_element, :general),
        career: Trends2026.element_trend_advice(day_element, :career),
        love: Trends2026.element_trend_advice(day_element, :love),
        daily: Trends2026.element_trend_advice(day_element, :daily),
        monthly: Trends2026.monthly_trend(Date.today.month),
        ten_god_advice: Trends2026.ten_god_trend_advice(daily_fortune[:ten_god])
      }
    }
  end

  # 궁합 분석
  def self.compatibility(person1_result, person2_result)
    score = calculate_compatibility_score(person1_result, person2_result)
    analysis = generate_compatibility_analysis(person1_result, person2_result, score)

    {
      score: score,
      grade: compatibility_grade(score),
      analysis: analysis
    }
  end

  private

  def self.analyze_personality(saju, ten_gods)
    day_stem = saju[:day][:stem]
    element = HeavenlyStems.element(day_stem)
    yinyang = HeavenlyStems.yinyang(day_stem)

    personalities = {
      "목" => {
        "양" => "큰 나무처럼 곧고 당당한 타입이에요! 🌳 새로운 일을 시작하는 걸 좋아하고, " \
                "주변 사람들을 자연스럽게 이끄는 리더십이 있어요. 정의감이 강해서 불의를 보면 못 참는 편이죠. " \
                "단, 가끔 고집이 세다는 소리를 들을 수 있으니 유연하게 생각하는 연습도 필요해요.",
        "음" => "풀이나 넝쿨처럼 유연하고 적응력이 뛰어난 타입이에요! 🌿 어디서든 잘 어울리고, " \
                "사람들과 협력하는 걸 잘해요. 겉으로 보면 부드럽지만 속은 의외로 단단하답니다. " \
                "눈치도 빠르고 상황 판단 능력이 좋아서 분위기 메이커 역할을 할 때도 많아요."
      },
      "화" => {
        "양" => "태양처럼 밝고 열정 넘치는 타입이에요! ☀️ 감성이 풍부하고 표현력이 뛰어나서 " \
                "주변 사람들에게 에너지를 주는 존재예요. 예술적 감각도 있고 트렌드에도 민감하죠. " \
                "다만 감정 기복이 있을 수 있으니, 마음을 다독이는 시간을 갖는 게 좋아요.",
        "음" => "촛불처럼 은은하고 따뜻한 타입이에요! 🕯️ 세심하게 남을 배려하고, " \
                "디테일한 것까지 잘 챙기는 스타일이에요. 조용히 빛나는 매력의 소유자라서 " \
                "오래 알수록 진가를 느끼는 사람들이 많답니다."
      },
      "토" => {
        "양" => "든든한 대지처럼 믿음직한 타입이에요! ⛰️ 중심을 잘 잡고 포용력이 넓어서 " \
                "주변에서 믿고 의지하는 사람이 많아요. 쉽게 흔들리지 않는 안정감이 장점이죠. " \
                "때로는 좀 더 과감하게 변화를 시도해보는 것도 좋아요.",
        "음" => "정원의 흙처럼 섬세하고 꼼꼼한 타입이에요! 🌱 작은 변화도 잘 감지하고, " \
                "사람들의 마음을 잘 읽어내요. 맡은 일은 끝까지 책임지는 성실한 스타일이에요. " \
                "걱정이 좀 많은 편이니, 때론 편하게 내려놓는 여유도 필요해요."
      },
      "금" => {
        "양" => "단단한 강철처럼 결단력 넘치는 타입이에요! ⚡ 한번 결정하면 끝까지 밀고 나가는 " \
                "추진력이 있어요. 원칙을 중시하고 의지가 정말 강하죠. " \
                "카리스마 너구나! 대신 가끔은 주변 사람의 의견도 귀 기울여보면 더 좋은 결과를 얻을 수 있어요.",
        "음" => "보석처럼 세련되고 품격 있는 타입이에요! 💎 미적 감각이 남다르고, " \
                "세밀한 판단력을 가지고 있어요. 깔끔하고 정돈된 걸 좋아하며, " \
                "은근히 완벽주의 성향이 있답니다. 가끔은 자신에게도 너그러워져 보세요."
      },
      "수" => {
        "양" => "바다처럼 깊고 넓은 사고를 가진 타입이에요! 🌊 큰 그림을 잘 보고, " \
                "전략적으로 생각하는 능력이 탁월해요. 추진력도 강하고 위기 대처 능력도 뛰어나죠. " \
                "때로는 자기만의 세계에 빠질 수 있으니 주변과 소통하는 시간을 의식적으로 가져보세요.",
        "음" => "맑은 시냇물처럼 총명하고 센스 있는 타입이에요! 💧 직관력이 뛰어나고 " \
                "분위기를 빠르게 읽는 능력이 있어요. 머리 회전이 빨라서 새로운 환경에도 " \
                "금방 적응하죠. 다만 너무 많이 생각하면 결정이 늦어질 수 있으니 가끔은 과감해져 봐요."
      }
    }

    personalities.dig(element, yinyang) || "다양한 매력을 가진 특별한 사람이에요! ✨"
  end

  def self.analyze_career(saju, ten_gods)
    element = HeavenlyStems.element(saju[:day][:stem])

    careers = {
      "목" => "성장과 발전에 관련된 분야에서 빛을 발해요! 📝 교육·강의, 콘텐츠 제작, 출판, " \
              "스타트업 창업, 건축·인테리어, 환경·ESG 관련 업종이 잘 맞아요. " \
              "사람을 키우고 새로운 것을 만드는 일에 보람을 느끼는 타입이에요.",
      "화" => "표현하고 빛나는 분야에서 능력을 발휘해요! 🎨 IT·테크, 디자인, 영상·미디어, " \
              "마케팅, 엔터테인먼트, 요리·카페 운영이 잘 맞아요. " \
              "트렌드를 읽고 창의적으로 표현하는 일이 천직이에요.",
      "토" => "안정적이고 신뢰가 중요한 분야에서 두각을 나타내요! 🏢 부동산, 금융·자산관리, " \
              "공무원, 컨설팅, 중개·플랫폼, 농업·식품 분야가 잘 맞아요. " \
              "맡은 일을 성실하게 해내는 모습이 인정받는 타입이에요.",
      "금" => "정확하고 체계적인 분야에서 실력을 발휘해요! ⚖️ 법률, 의료, 금융·핀테크, " \
              "기계·제조, 보석·명품, 품질관리 쪽이 잘 맞아요. " \
              "원칙과 기준이 확실한 전문가로 인정받을 수 있어요.",
      "수" => "지식과 소통이 중요한 분야에서 두각을 나타내요! 🌐 무역, 물류, 여행·관광, " \
              "연구·분석, 외교·국제업무, 철학·심리 쪽이 잘 맞아요. " \
              "넓은 시야와 분석력으로 복잡한 문제도 척척 풀어내는 타입이에요."
    }

    careers[element] || "다양한 분야에서 능력을 발휘할 수 있는 팔방미인이에요! 🌟"
  end

  def self.analyze_love(saju, ten_gods)
    element = HeavenlyStems.element(saju[:day][:stem])

    love_styles = {
      "목" => "함께 성장하는 관계를 원하는 타입이에요! 🌱 서로 응원하고 발전하는 커플이 이상형이에요. " \
              "연인에게 자유를 존중해주지만, 그만큼 나의 자유도 중요하게 생각해요. " \
              "소소한 일상보다는 함께 새로운 경험을 하는 데이트를 더 좋아할 수 있어요.",
      "화" => "열정적이고 로맨틱한 연애를 하는 타입이에요! 🔥 좋아하면 적극적으로 표현하고, " \
              "분위기 만들기도 잘해요. 깜짝 이벤트, 감동적인 순간을 만드는 데 재능이 있죠. " \
              "다만 감정에 충실한 편이라 가끔은 이성적으로 생각해보는 것도 좋아요.",
      "토" => "한번 사랑하면 끝까지 가는 진심파 타입이에요! 💛 안정적이고 헌신적인 사랑을 하며, " \
              "연인에게 든든한 버팀목이 되어줘요. 가정적이고 따뜻한 분위기를 좋아해요. " \
              "너무 참기만 하지 말고, 솔직하게 감정을 표현하는 연습도 필요해요.",
      "금" => "품격 있고 세련된 연애를 하는 타입이에요! ✨ 첫인상과 매너를 중시하고, " \
              "격식 있는 데이트를 좋아해요. 쉽게 마음을 열지는 않지만 한번 마음을 주면 깊어요. " \
              "가끔 벽을 쌓는 것처럼 보일 수 있으니, 솔직한 대화를 많이 해보면 좋아요.",
      "수" => "깊고 의미 있는 교감을 중시하는 타입이에요! 🌙 정신적 연결이 중요하고, " \
              "대화가 잘 통하는 사람에게 끌려요. 외면보다 내면의 깊이에 매력을 느끼는 편이에요. " \
              "가끔 너무 깊이 생각해서 연애를 복잡하게 만들 수 있으니, 가볍게 즐기는 것도 연습해봐요."
    }

    love_styles[element] || "진심을 다해 사랑하는 따뜻한 사람이에요! 💕"
  end

  def self.calculate_compatibility_score(p1, p2)
    score = 50
    p1_elem = p1[:saju][:day][:element]
    p2_elem = p2[:saju][:day][:element]

    # 상생 보너스
    if FiveElements.generates?(p1_elem, p2_elem) || FiveElements.generates?(p2_elem, p1_elem)
      score += 25
    end

    # 같은 오행
    score += 15 if p1_elem == p2_elem

    # 상극 패널티
    if FiveElements.overcomes?(p1_elem, p2_elem) || FiveElements.overcomes?(p2_elem, p1_elem)
      score -= 10
    end

    # 지지 합 보너스
    p1_branches = p1[:saju][:pillars].map { |p| p[:branch] }
    p2_branches = p2[:saju][:pillars].map { |p| p[:branch] }

    six_harmony_pairs = [ %w[자 축], %w[인 해], %w[묘 술], %w[진 유], %w[사 신], %w[오 미] ]
    six_harmony_pairs.each do |pair|
      if (p1_branches.include?(pair[0]) && p2_branches.include?(pair[1])) ||
         (p1_branches.include?(pair[1]) && p2_branches.include?(pair[0]))
        score += 5
      end
    end

    score.clamp(30, 99)
  end

  def self.compatibility_grade(score)
    if score >= 90 then "천생연분 💕"
    elsif score >= 80 then "매우 좋음 💗"
    elsif score >= 70 then "좋음 💖"
    elsif score >= 60 then "보통 💛"
    elsif score >= 50 then "노력 필요 🧡"
    else "주의 필요 💔"
    end
  end

  def self.generate_compatibility_analysis(p1, p2, score)
    p1_elem = p1[:saju][:day][:element]
    p2_elem = p2[:saju][:day][:element]
    p1_name = FiveElements::ELEMENT_NAMES[p1_elem]
    p2_name = FiveElements::ELEMENT_NAMES[p2_elem]

    analysis = []
    if FiveElements.generates?(p1_elem, p2_elem)
      analysis << "#{p1_name}이(가) #{p2_name}을(를) 생해주는 '상생(相生)' 관계예요! 서로에게 좋은 에너지를 주고받을 수 있는 멋진 조합이에요. 🌿"
    elsif FiveElements.generates?(p2_elem, p1_elem)
      analysis << "#{p2_name}이(가) #{p1_name}을(를) 응원해주는 '상생(相生)' 관계예요! 함께할수록 시너지가 나는 궁합이에요. 🌿"
    elsif FiveElements.overcomes?(p1_elem, p2_elem)
      analysis << "#{p1_name}과 #{p2_name}은 '상극(相剋)' 관계라 가끔 부딪힐 수 있어요. 하지만 서로 다르기 때문에 배울 점도 많답니다! 💫"
    elsif p1_elem == p2_elem
      analysis << "같은 #{p1_name}의 기운을 가진 두 사람! 서로 공감대도 크고 이해도가 높은 관계예요. 🤝"
    end

    analysis << "전체 궁합 점수: #{score}점"
    analysis.join(" ")
  end
end
