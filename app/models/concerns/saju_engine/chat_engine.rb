# frozen_string_literal: true

module SajuEngine
  module ChatEngine
    CATEGORIES = {
      "오늘의 운세" => :daily,
      "연애운" => :love,
      "재물운" => :wealth,
      "커리어" => :career,
      "건강" => :health,
      "인간관계" => :social,
      "올해 운세" => :yearly,
      "성격" => :personality,
      "궁합" => :compatibility
    }.freeze

    # 질문 분류
    def self.categorize(question)
      return :daily if question.match?(/오늘|일일|데일리|today/i)
      return :love if question.match?(/연애|사랑|애정|결혼|연인|짝|썸|인연|이별|재회/i)
      return :wealth if question.match?(/재물|돈|재테크|투자|수입|부동산|주식|재산|수입|월급/i)
      return :career if question.match?(/직업|커리어|직장|취업|이직|승진|사업|업무|일|사업운/i)
      return :health if question.match?(/건강|몸|체력|운동|스트레스|병|아프/i)
      return :social if question.match?(/인간관계|친구|사람|대인|동료|상사|가족|부모/i)
      return :yearly if question.match?(/올해|2026|연간|내년|금년/i)
      return :personality if question.match?(/성격|성향|특징|나는|내가|MBTI/i)
      return :compatibility if question.match?(/궁합|상성|잘 맞|맞는/i)

      :general
    end

    # 사주 기반 대화 응답 생성
    def self.respond(question, analysis)
      category = categorize(question)
      saju = analysis[:saju]
      day_element = SajuEngine::HeavenlyStems.element(saju[:day][:stem])

      case category
      when :daily
        daily_response(analysis)
      when :love
        love_response(analysis, day_element)
      when :wealth
        wealth_response(analysis, day_element)
      when :career
        career_response(analysis, day_element)
      when :health
        health_response(analysis, day_element)
      when :social
        social_response(analysis, day_element)
      when :yearly
        yearly_response(analysis, day_element)
      when :personality
        personality_response(analysis)
      when :compatibility
        compatibility_response(analysis, day_element)
      else
        general_response(analysis, day_element)
      end
    end

    private_class_method def self.daily_response(analysis)
      fortune = analysis[:daily_fortune]
      trend = analysis[:trend_2026]

      messages = []
      messages << "오늘 운세를 봐줄게! 🔮"
      messages << "오늘의 운세 점수는 #{fortune[:score]}점이야! #{score_emoji(fortune[:score])}"
      messages << "오늘의 십성은 '#{fortune[:ten_god]}'이야. #{fortune[:description]}"

      if trend && trend[:ten_god_advice]
        messages << "💡 #{trend[:ten_god_advice]}"
      end

      lucky = fortune[:lucky_items]
      if lucky
        lucky_msg = []
        lucky_msg << "🎨 행운의 색: #{lucky[:color]}" if lucky[:color]
        lucky_msg << "🔢 행운의 숫자: #{lucky[:number]}" if lucky[:number]
        lucky_msg << "🧭 행운의 방향: #{lucky[:direction]}" if lucky[:direction]
        messages << lucky_msg.join("\n")
      end

      messages
    end

    private_class_method def self.love_response(analysis, element)
      messages = []
      messages << "연애운을 봐줄게! 💕"
      messages << analysis[:love].to_s

      trend = analysis[:trend_2026]
      if trend && trend[:love]
        messages << "🔥 2026 연애 트렌드:\n#{trend[:love]}"
      end

      # 오행별 연애 팁
      love_tips = {
        "목" => "목(木)인 너는 성장하는 관계를 원하는 타입이야! 서로 영감을 주는 사람이 인연이 될 수 있어. 올해는 취미 모임이나 스터디에서 좋은 만남의 기회가 있을지도! 🌱",
        "화" => "화(火)인 너는 열정적이고 직진형이야! 첫눈에 반하는 스타일이지만, 올해는 천천히 알아가는 연애가 더 잘 맞을 수 있어. SNS나 온라인에서의 인연에 주목! 🔥",
        "토" => "토(土)인 너는 안정적이고 따뜻한 연애를 하는 타입이야! 신뢰를 쌓아가는 관계가 잘 맞아. 올해는 소개팅이나 지인의 소개가 좋은 인연으로 이어질 수 있어! 🤎",
        "금" => "금(金)인 너는 깔끔하고 원칙이 있는 연애를 하는 타입이야! 서로의 가치관이 맞는 사람이 좋아. 올해는 직장이나 전문 분야에서의 만남에 주목! ✨",
        "수" => "수(水)인 너는 감성적이고 깊은 연애를 하는 타입이야! 마음의 교류가 중요해. 올해는 문화예술 활동이나 여행에서 특별한 만남이 있을 수 있어! 💧"
      }
      messages << (love_tips[element] || "너만의 매력으로 좋은 인연을 만날 수 있어! 💕")

      messages
    end

    private_class_method def self.wealth_response(analysis, element)
      messages = []
      messages << "재물운을 봐줄게! 💰"

      wealth_advice = {
        "목" => "목(木)의 기운은 성장과 발전을 의미해! 올해는 자기 투자(교육, 스킬업)가 장기적으로 큰 수익으로 돌아올 수 있어. AI 관련 역량 투자 추천! 📈",
        "화" => "화(火)의 기운은 확산과 화려함! 올해는 SNS, 콘텐츠, 크리에이터 경제 쪽에서 수익 기회가 보여. 하지만 충동 소비 주의! 🔥💸",
        "토" => "토(土)의 기운은 안정과 축적! 올해는 부동산이나 안정적 투자 상품이 유리해. 꾸준한 저축과 장기 투자가 정답이야! 🏠",
        "금" => "금(金)의 기운은 명확한 판단과 실행! 올해는 ETF, 분산 투자가 유리해. 하나에 몰빵하지 말고 포트폴리오를 다양하게! ⚖️",
        "수" => "수(水)의 기운은 유연함과 적응력! 올해는 변화에 빠르게 대응하는 투자가 유리해. 핀테크, 가상자산에서 기회가 보이지만 리스크 관리 필수! 💧"
      }
      messages << (wealth_advice[element] || "올해 재물운은 꾸준한 관리가 핵심이야! 💪")

      trend = analysis[:trend_2026]
      if trend && trend[:career]
        messages << "📊 #{trend[:career]}"
      end

      messages
    end

    private_class_method def self.career_response(analysis, element)
      messages = []
      messages << "커리어 운을 봐줄게! 💼"
      messages << analysis[:career].to_s

      trend = analysis[:trend_2026]
      if trend && trend[:career]
        messages << "🚀 2026 커리어 트렌드:\n#{trend[:career]}"
      end

      messages
    end

    private_class_method def self.health_response(analysis, element)
      messages = []
      messages << "건강운을 봐줄게! 🏥"

      health_advice = {
        "목" => "목(木)은 간/담 계통과 관련 있어! 올해는 눈의 피로, 근육 긴장에 주의하고, 스트레칭과 산책을 꾸준히 해봐! 🌿",
        "화" => "화(火)는 심장/소장 계통과 관련 있어! 올해는 충분한 수면이 특히 중요해. 카페인 줄이고 명상이나 호흡법을 시도해봐! ❤️",
        "토" => "토(土)는 위장/소화 계통과 관련 있어! 올해는 규칙적인 식사가 핵심이야. 야식 줄이고 소화에 좋은 음식 위주로! 🍵",
        "금" => "금(金)은 폐/대장 계통과 관련 있어! 올해는 호흡기 관리가 중요해. 유산소 운동과 깨끗한 공기 확보에 신경 써! 🌬️",
        "수" => "수(水)는 신장/방광 계통과 관련 있어! 올해는 수분 섭취와 하체 운동이 중요해. 반신욕이나 수영이 좋을 수 있어! 💦"
      }
      messages << (health_advice[element] || "올해는 전반적인 체력 관리에 신경 쓰는 게 좋아! 💪")
      messages << "💡 2026 건강 트렌드: AI 건강 관리 앱을 활용해보는 건 어때? 개인 맞춤 건강 관리가 대세야! 📱"

      messages
    end

    private_class_method def self.social_response(analysis, element)
      messages = []
      messages << "인간관계 운을 봐줄게! 👥"

      social_advice = {
        "목" => "목(木)인 너는 리더십이 있어서 사람들이 따르지만, 가끔 고집이 세다는 소리를 들을 수 있어! 올해는 상대의 의견도 수용하는 열린 마음이 필요해 🌳",
        "화" => "화(火)인 너는 분위기 메이커! 하지만 가끔 너무 직설적일 수 있으니, 올해는 한 템포 쉬고 말하는 연습을 해봐 🔥",
        "토" => "토(土)인 너는 신뢰감 있는 사람이야! 올해는 네 주변의 소중한 사람들에게 먼저 연락해보는 게 좋아. 작은 관심이 큰 인연을 만들어 🤗",
        "금" => "금(金)인 너는 원칙적이고 공정해! 올해는 약간의 유연함을 더하면 인간관계가 더 풍요로워질 거야 ⚖️",
        "수" => "수(水)인 너는 공감능력이 뛰어나! 올해는 네 에너지를 지키면서 관계하는 법을 배워봐. 모든 사람을 다 챙기려다 지칠 수 있어 💧"
      }
      messages << (social_advice[element] || "좋은 인연은 내가 먼저 다가갈 때 찾아오기도 해! 😊")

      messages
    end

    private_class_method def self.yearly_response(analysis, element)
      messages = []
      messages << "2026년 올해 운세를 봐줄게! 🐴"

      trend = analysis[:trend_2026]
      if trend
        messages << "올해는 #{trend[:year_info][:nickname]}! #{trend[:general]}"
        messages << "💼 커리어: #{trend[:career]}" if trend[:career]
        messages << "💕 연애: #{trend[:love]}" if trend[:love]
        messages << "📅 이달의 포인트: #{trend[:monthly]}" if trend[:monthly]
      end

      messages
    end

    private_class_method def self.personality_response(analysis)
      messages = []
      messages << "너의 성격을 분석해볼게! 🔍"
      messages << analysis[:personality].to_s

      saju = analysis[:saju]
      messages << "📊 너의 오행 분포: #{saju[:distribution].map { |k, v| "#{k}(#{v})" }.join(', ')}"
      messages << "⚖️ 오행 밸런스: #{saju[:balance]}"

      messages
    end

    private_class_method def self.compatibility_response(analysis, element)
      messages = []
      messages << "궁합에 대해 알려줄게! 💑"

      compat_elements = {
        "목" => "목(木)과 가장 잘 맞는 오행은 수(水)! 물이 나무를 키워주는 상생 관계야. 화(火)와도 잘 맞아 — 서로 에너지를 나눌 수 있거든! 🌿💧",
        "화" => "화(火)와 가장 잘 맞는 오행은 목(木)! 나무가 불을 키워주는 상생 관계야. 토(土)와도 잘 어울려 — 서로 안정감을 줄 수 있어! 🔥🌳",
        "토" => "토(土)와 가장 잘 맞는 오행은 화(火)! 불이 흙을 만들어주는 상생 관계야. 금(金)과도 잘 맞아 — 서로 신뢰를 쌓을 수 있어! 🪨🔥",
        "금" => "금(金)과 가장 잘 맞는 오행은 토(土)! 흙이 쇠를 만들어주는 상생 관계야. 수(水)와도 잘 어울려 — 서로 보완이 돼! ⚔️🪨",
        "수" => "수(水)와 가장 잘 맞는 오행은 금(金)! 쇠가 물을 생성해주는 상생 관계야. 목(木)과도 잘 맞아 — 함께 성장할 수 있어! 💧⚔️"
      }
      messages << (compat_elements[element] || "더 자세한 궁합은 '궁합' 메뉴에서 확인할 수 있어! 💕")
      messages << "자세한 궁합 분석은 메뉴의 '💕 궁합'에서 두 사람의 생년월일을 입력해봐!"

      messages
    end

    private_class_method def self.general_response(analysis, element)
      messages = []
      messages << "좋은 질문이야! 🐱"

      greetings = [
        "반가워! 나는 1분 사주야~ 뭐가 궁금해? 아래 버튼을 눌러도 되고, 직접 질문해도 돼! 😸",
        "안녕! 오늘도 좋은 하루 보내고 있어? 사주에 대해 궁금한 거 물어봐! 🐱",
        "냥~ 반가워! 너의 사주를 바탕으로 이것저것 알려줄 수 있어! 뭐가 궁금해? ✨"
      ]
      messages << greetings.sample

      trend = analysis[:trend_2026]
      if trend && trend[:daily]
        messages << "오늘의 한 마디: #{trend[:daily]}"
      end

      messages
    end

    private_class_method def self.score_emoji(score)
      case score
      when 80..100 then "대박! 🎊"
      when 60..79 then "좋은 날이야! 😊"
      when 40..59 then "무난한 하루가 될 거야~ 🙂"
      else "오늘은 좀 조심하는 게 좋겠어 💪"
      end
    end
  end
end
