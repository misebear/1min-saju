# frozen_string_literal: true

module SajuEngine
  module DreamEngine
    # 꿈 카테고리별 키워드 → 해몽 매핑
    DREAM_DB = {
      # 동물 꿈
      "뱀" => { meaning: "뱀꿈은 전통적으로 '재물의 신'이 찾아오는 꿈으로 해석돼요. 특히 큰 구렁이가 집에 들어오거나, 뱀이 몸을 감싸는 꿈은 예상치 못한 큰 돈이 들어올 조짐이에요. 뱀이 허물을 벗는 꿈이라면 인생의 새로운 전환기를 맞이하게 된다는 뜻! 다만 뱀에게 물리는 꿈이라면 건강 관리에 신경 쓰라는 경고일 수 있어요.", score: 88, category: "재물", emoji: "🐍", element: "수" },
      "용" => { meaning: "용꿈은 동양에서 최고의 길몽으로 꼽혀요! 하늘을 나는 용은 승진·합격·대박을 의미하고, 용이 여의주를 물고 있으면 큰 소원이 이루어질 징조예요. 황금색 용은 재물운, 청룡은 건강과 성장, 흑룡은 권력과 명예를 상징해요. 용꿈을 꿨다면 지금 도전하고 있는 일에 자신감을 가져도 좋아요!", score: 95, category: "성공", emoji: "🐲", element: "목" },
      "호랑이" => { meaning: "호랑이는 권위·용기·리더십의 상징이에요. 호랑이가 다가오는 꿈은 직장에서 승진하거나 사업에서 성공할 수 있다는 뜻이에요. 특히 호랑이를 타고 다니는 꿈은 큰 권력을 얻게 될 길몽! 하지만 호랑이에게 쫓기는 꿈이라면 현실에서 부담감이나 두려움을 느끼고 있다는 신호일 수 있어요. 용기를 내서 문제를 직접 맞서보세요.", score: 85, category: "성공", emoji: "🐯", element: "금" },
      "돼지" => { meaning: "돼지꿈은 '돈꿈'의 대명사! 통통한 돼지가 집안으로 들어오는 꿈은 뜻밖의 재물이 생길 조짐이에요. 새끼 돼지를 안고 있으면 작은 수입이 꾸준히 생기고, 금색 돼지는 대박 재물운! 돼지고기를 먹는 꿈도 재운 상승을 의미해요. 이 꿈을 꿨다면 로또를 사보는 것도 좋겠어요. 🎰", score: 92, category: "재물", emoji: "🐷", element: "토" },
      "물고기" => { meaning: "물고기 꿈은 풍요와 번성의 상징이에요. 큰 잉어를 잡는 꿈은 입학·취업 등 기쁜 소식이 올 징조이고, 금붕어는 소소한 행운을, 활짝 뛰는 물고기는 사업 번창을 의미해요. 물고기떼가 헤엄치는 꿈이면 재물이 쏟아질 수 있어요! 다만 죽은 물고기는 기회를 놓칠 수 있다는 경고.", score: 82, category: "재물", emoji: "🐟", element: "수" },
      "개" => { meaning: "개꿈은 인간관계의 거울이에요. 순한 개가 꼬리를 치며 다가오면 충직한 친구나 동료의 도움을 받을 수 있어요. 큰 개가 집을 지키면 집안이 안전하다는 뜻이고, 강아지는 새로운 인연의 등장! 하지만 개에게 물리는 꿈이라면 가까운 사람과의 다툼에 주의하세요.", score: 70, category: "인간관계", emoji: "🐕", element: "토" },
      "고양이" => { meaning: "고양이 꿈은 직감과 감성이 예민해지는 시기를 뜻해요. 고양이가 무릎에 올라오면 편안한 일상이, 야옹하고 우는 고양이는 누군가 당신의 관심을 원한다는 신호예요. 검은 고양이는 숨겨진 진실이 드러날 수 있고, 흰 고양이는 순수한 애정이 찾아올 수 있어요.", score: 65, category: "인간관계", emoji: "🐱", element: "목" },
      "새" => { meaning: "새 꿈은 자유와 새로운 기회를 상징해요. 하늘 높이 나는 새는 현재의 한계를 뛰어넘을 수 있다는 뜻이고, 아름다운 새소리는 기쁜 소식이 찾아올 징조예요. 새가 둥지를 틀면 가정의 안정을, 새가 알을 낳으면 창작이나 새 프로젝트의 성공을 의미해요!", score: 78, category: "기회", emoji: "🕊️", element: "화" },
      "말" => { meaning: "말꿈은 속도와 진취의 상징! 말을 타고 달리는 꿈은 하던 일이 빠르게 성과를 내는 길몽이에요. 백마는 순수한 성공을, 검은 말은 강한 추진력을, 날개 달린 말은 상상 이상의 도약을 의미해요. 말이 힘차게 울면 좋은 소식이 멀리서 찾아올 수 있어요.", score: 80, category: "성공", emoji: "🐴", element: "화" },
      "소" => { meaning: "소 꿈은 근면·성실의 보상을 뜻해요. 논밭에서 일하는 소는 꾸준한 노력이 결실을 맺을 거라는 메시지이고, 황소는 강인한 의지력을 상징해요. 소가 새끼를 낳는 꿈이면 가정에 경사가 생길 수 있고, 젖소 꿈은 풍요와 여유를 의미합니다.", score: 75, category: "성공", emoji: "🐂", element: "토" },
      "거북이" => { meaning: "거북이 꿈은 장수·건강·지혜의 상징이에요. 큰 바다거북은 인생에서 안정적인 기반을 쌓게 될 거라는 뜻이고, 거북이 등에 올라타면 귀인의 도움을 받을 수 있어요. 거북이가 알을 낳으면 재물이 불어날 징조! 느리지만 확실한 성공을 의미하는 꿈이에요.", score: 80, category: "건강", emoji: "🐢", element: "수" },
      "토끼" => { meaning: "토끼 꿈은 사랑과 행운의 메신저! 하얀 토끼는 순수한 사랑이 찾아오고, 달에서 떡을 찧는 토끼는 소원성취의 길몽이에요. 토끼가 뛰어다니면 활발한 사교활동이 예상되고, 아기 토끼는 새로운 연인의 출현을 암시할 수 있어요.", score: 72, category: "연애", emoji: "🐰", element: "목" },
      "곰" => { meaning: "곰은 힘과 보호의 상징으로, 태몽일 경우 아들을 상징하는 대표적인 꿈이에요. 곰이 숲에서 나타나면 든든한 보호자나 조력자가 나타날 징조이고, 아기 곰은 귀여운 인연이나 새 프로젝트를 의미해요. 겨울잠에서 깨어나는 곰은 긴 준비 기간이 끝나고 드디어 성과를 낼 때!", score: 78, category: "가족", emoji: "🐻", element: "토" },
      "나비" => { meaning: "나비 꿈은 아름다운 변화와 성장의 메시지예요. 화려한 나비는 인생의 전환점이 다가오고 있다는 뜻이고, 나비가 꽃에 앉으면 사랑이 이루어질 징조! 호랑나비는 재물운, 노란 나비는 행복한 소식을 의미하고, 나비가 몸에 앉으면 귀인이 찾아올 수 있어요.", score: 75, category: "변화", emoji: "🦋", element: "화" },
      "벌레" => { meaning: "벌레 꿈은 사소하지만 신경 쓰이는 일이 있다는 뜻이에요. 하지만 걱정 마세요! 벌레를 잡거나 없애면 곧 해결된다는 긍정적 신호예요. 많은 벌레떼는 복잡한 인간관계를, 예쁜 무당벌레는 작은 행운을 의미해요.", score: 45, category: "주의", emoji: "🐛", element: "토" },

      # 자연/날씨 꿈
      "비" => { meaning: "정화와 새로운 시작! 마음의 짐을 내려놓을 때가 왔어요.", score: 70, category: "변화", emoji: "🌧️", element: "수" },
      "눈" => { meaning: "깨끗한 마음으로 새 출발! 순수한 감정이 찾아올 수 있어요.", score: 72, category: "변화", emoji: "❄️", element: "수" },
      "바다" => { meaning: "넓은 세계로의 도전! 해외 관련 좋은 소식이 있을 수 있어요.", score: 78, category: "기회", emoji: "🌊", element: "수" },
      "산" => { meaning: "목표 달성! 높은 산일수록 큰 성취를 의미해요.", score: 82, category: "성공", emoji: "⛰️", element: "토" },
      "꽃" => { meaning: "사랑과 아름다움! 연애운이 상승하거나 기쁜 소식이 있을 거예요.", score: 80, category: "연애", emoji: "🌸", element: "목" },
      "나무" => { meaning: "성장과 발전! 큰 나무일수록 튼튼한 기반을 의미해요.", score: 75, category: "성공", emoji: "🌳", element: "목" },
      "불" => { meaning: "열정과 에너지! 하지만 화재는 변화를 의미할 수 있어요.", score: 68, category: "변화", emoji: "🔥", element: "화" },
      "물" => { meaning: "감정과 재물! 맑은 물은 좋은 운세, 탁한 물은 주의가 필요해요.", score: 72, category: "재물", emoji: "💧", element: "수" },
      "하늘" => { meaning: "무한한 가능성! 맑은 하늘은 밝은 미래를 의미해요.", score: 85, category: "기회", emoji: "🌤️", element: "화" },
      "달" => { meaning: "여성적 에너지와 직감! 달이 밝을수록 통찰력이 높아져요.", score: 78, category: "직감", emoji: "🌙", element: "금" },
      "해" => { meaning: "성공과 영광! 태양은 최고의 길몽 중 하나예요.", score: 90, category: "성공", emoji: "☀️", element: "화" },
      "별" => { meaning: "희망과 행운! 별이 밝을수록 좋은 징조예요.", score: 82, category: "행운", emoji: "⭐", element: "금" },
      "무지개" => { meaning: "행운과 축복! 소원이 이루어질 수 있는 좋은 꿈이에요.", score: 88, category: "행운", emoji: "🌈", element: "화" },
      "지진" => { meaning: "큰 변화가 다가오고 있어요. 준비하면 기회가 될 수 있어!", score: 55, category: "변화", emoji: "🌍", element: "토" },
      "태풍" => { meaning: "혼란 속에서도 중심을 잡으면 좋은 결과가 있을 거예요.", score: 50, category: "주의", emoji: "🌪️", element: "금" },

      # 사물/상황 꿈
      "돈" => { meaning: "재물운 상승! 돈을 줍는 꿈은 예상치 못한 수입이 생길 수 있어요.", score: 85, category: "재물", emoji: "💰", element: "금" },
      "금" => { meaning: "대박! 금은 최고의 재물운을 의미해요.", score: 92, category: "재물", emoji: "🪙", element: "금" },
      "집" => { meaning: "안정과 가정의 행복! 새 집은 새로운 시작을 의미해요.", score: 78, category: "가족", emoji: "🏠", element: "토" },
      "차" => { meaning: "인생의 방향! 운전하는 꿈은 삶의 주도권을 잡고 있다는 뜻이에요.", score: 72, category: "인생", emoji: "🚗", element: "금" },
      "비행기" => { meaning: "도약과 상승! 높이 날수록 큰 성취를 의미해요.", score: 82, category: "성공", emoji: "✈️", element: "화" },
      "배" => { meaning: "새로운 여정! 큰 배는 큰 기회를 의미해요.", score: 75, category: "기회", emoji: "🚢", element: "수" },
      "열쇠" => { meaning: "문제의 해결책을 찾게 될 거예요! 새로운 문이 열려요.", score: 80, category: "기회", emoji: "🔑", element: "금" },
      "거울" => { meaning: "자기 자신을 돌아보는 시간이 필요해요. 내면의 성장!", score: 65, category: "성장", emoji: "🪞", element: "금" },
      "칼" => { meaning: "결단이 필요한 시기! 과감한 결정이 좋은 결과를 가져올 수 있어요.", score: 60, category: "결단", emoji: "🗡️", element: "금" },
      "음식" => { meaning: "풍요와 만족! 맛있는 음식 꿈은 좋은 일이 생길 징조예요.", score: 75, category: "행운", emoji: "🍽️", element: "토" },
      "옷" => { meaning: "새 옷은 새로운 역할이나 이미지 변화를 의미해요.", score: 70, category: "변화", emoji: "👗", element: "목" },
      "책" => { meaning: "지혜와 학습! 시험이나 자격증에 좋은 결과가 있을 수 있어요.", score: 75, category: "학업", emoji: "📚", element: "목" },
      "선물" => { meaning: "예상치 못한 행운! 누군가에게 좋은 소식을 받을 수 있어요.", score: 80, category: "행운", emoji: "🎁", element: "토" },

      # 행동/상황 꿈
      "날다" => { meaning: "자유와 해방감! 현재의 제약에서 벗어나고 싶은 마음이에요.", score: 78, category: "자유", emoji: "🦅", element: "화" },
      "떨어지다" => { meaning: "불안감의 표현이지만, 새로운 시작을 의미하기도 해요.", score: 50, category: "주의", emoji: "😰", element: "토" },
      "도망" => { meaning: "현실의 스트레스에서 벗어나고 싶은 마음! 휴식이 필요해요.", score: 45, category: "주의", emoji: "🏃", element: "수" },
      "죽다" => { meaning: "걱정 마! 죽음 꿈은 새로운 시작과 재탄생을 의미하는 길몽이에요!", score: 72, category: "변화", emoji: "🔄", element: "수" },
      "울다" => { meaning: "감정의 해방! 억눌린 감정이 풀리면서 마음이 가벼워질 거예요.", score: 60, category: "감정", emoji: "😢", element: "수" },
      "웃다" => { meaning: "기쁜 일이 생길 징조! 주변 사람들과 좋은 시간을 보낼 수 있어요.", score: 80, category: "행운", emoji: "😄", element: "화" },
      "싸우다" => { meaning: "내면의 갈등 해소! 갈등을 극복하면 더 강해질 수 있어요.", score: 55, category: "관계", emoji: "💢", element: "금" },
      "시험" => { meaning: "자기 점검의 시기! 준비한 것에 대한 평가가 다가오고 있어요.", score: 65, category: "학업", emoji: "📝", element: "목" },
      "결혼" => { meaning: "새로운 파트너십! 사업이든 연애든 좋은 결합이 있을 수 있어요.", score: 82, category: "연애", emoji: "💒", element: "화" },
      "임신" => { meaning: "새로운 프로젝트나 아이디어의 시작! 창의적 에너지가 넘쳐요.", score: 80, category: "시작", emoji: "🤰", element: "토" },
      "이" => { meaning: "이가 빠지는 꿈은 변화의 시기! 가까운 사람과의 관계에 주의하세요.", score: 50, category: "주의", emoji: "🦷", element: "금" },
      "치아" => { meaning: "이가 빠지는 꿈은 변화의 시기! 가까운 사람과의 관계에 주의하세요.", score: 50, category: "주의", emoji: "🦷", element: "금" },

      # 사람
      "아기" => { meaning: "새로운 시작과 가능성! 기쁜 소식이 찾아올 수 있어요.", score: 82, category: "시작", emoji: "👶", element: "토" },
      "부모" => { meaning: "가정의 안정과 보호! 가족과의 유대가 강화되는 시기예요.", score: 75, category: "가족", emoji: "👨‍👩‍👧", element: "토" },
      "연예인" => { meaning: "인정과 주목에 대한 욕구! 너도 빛날 수 있어요.", score: 68, category: "자아", emoji: "🌟", element: "화" },
      "고인" => { meaning: "돌아가신 분의 꿈은 조언이나 보호의 메시지일 수 있어요.", score: 72, category: "메시지", emoji: "🕊️", element: "수" },
      "귀신" => { meaning: "무의식의 두려움! 하지만 직면하면 성장할 수 있어요.", score: 48, category: "주의", emoji: "👻", element: "수" },
      "낯선사람" => { meaning: "새로운 만남이나 기회! 나의 숨겨진 면을 의미하기도 해요.", score: 65, category: "기회", emoji: "🤝", element: "목" },

      # 숫자
      "숫자" => { meaning: "숫자 꿈은 행운의 숫자일 수 있어요! 로또에 활용해보세요.", score: 75, category: "행운", emoji: "🔢", element: "금" },

      # 색깔
      "빨간색" => { meaning: "열정과 에너지! 적극적으로 행동하면 좋아요.", score: 72, category: "행동", emoji: "🔴", element: "화" },
      "파란색" => { meaning: "평화와 안정! 마음의 평화를 찾을 수 있는 시기예요.", score: 75, category: "안정", emoji: "🔵", element: "수" },
      "노란색" => { meaning: "행복과 낙관! 기쁜 소식이 찾아올 수 있어요.", score: 78, category: "행운", emoji: "🟡", element: "토" },
      "초록색" => { meaning: "성장과 치유! 건강과 회복의 시기예요.", score: 75, category: "건강", emoji: "🟢", element: "목" },
      "검은색" => { meaning: "미지의 영역! 두려움과 가능성이 공존해요.", score: 55, category: "미지", emoji: "⚫", element: "수" },
      "흰색" => { meaning: "순수와 새로운 시작! 깨끗한 마음으로 출발할 때예요.", score: 78, category: "시작", emoji: "⚪", element: "금" }
    }.freeze

    # 카테고리별 일반 해석
    CATEGORY_ADVICE = {
      "재물" => "재물과 관련된 꿈이에요! 이 시기에 경제적인 기회를 잘 살펴봐. 💰",
      "성공" => "성공과 성취의 기운이 느껴져! 지금 하고 있는 일에 자신감을 가져봐. 🏆",
      "연애" => "사랑의 기운이 다가오고 있어! 주변을 잘 살펴봐. 💕",
      "건강" => "건강에 대한 메시지야! 몸과 마음의 균형을 잘 챙겨. 🏥",
      "기회" => "새로운 기회가 다가오고 있어! 망설이지 말고 잡아봐. ✨",
      "변화" => "변화의 시기야! 두려워하지 말고 흐름에 몸을 맡겨봐. 🔄",
      "가족" => "가족과 관련된 메시지야! 소중한 사람들에게 연락해봐. 👨‍👩‍👧",
      "주의" => "주의가 필요한 시기야! 큰 결정은 신중하게 해. ⚠️",
      "행운" => "행운이 찾아올 수 있어! 좋은 기운을 즐겨봐. 🍀",
      "학업" => "학습과 성장의 시기야! 공부나 자기개발에 힘써봐. 📚"
    }.freeze

    # 꿈 해석 메인 함수
    def self.interpret(dream_text)
      keywords_found = find_keywords(dream_text)

      if keywords_found.empty?
        return {
          keywords: [],
          interpretations: [],
          overall_score: 70,
          overall_message: "흥미로운 꿈이야! 꿈에서 특별히 인상 깊었던 것을 더 자세히 알려주면 더 정확한 해몽을 해줄 수 있어. 🐱",
          lucky_number: rand(1..45),
          advice: "꿈은 무의식의 메시지야! 꿈 속에서 느꼈던 감정을 잘 기억해봐. ✨",
          category: "일반"
        }
      end

      interpretations = keywords_found.map { |kw| DREAM_DB[kw] }
      overall_score = (interpretations.sum { |i| i[:score] }.to_f / interpretations.size).round

      primary = interpretations.max_by { |i| i[:score] }
      category = primary[:category]
      advice = CATEGORY_ADVICE[category] || "꿈은 무의식의 소중한 메시지야! ✨"

      # 행운의 숫자 생성 (꿈 키워드 기반)
      seed = dream_text.bytes.sum
      lucky_numbers = (1..45).to_a.shuffle(random: Random.new(seed)).first(3).sort

      {
        keywords: keywords_found,
        interpretations: interpretations,
        overall_score: overall_score,
        overall_message: generate_overall_message(overall_score),
        lucky_numbers: lucky_numbers,
        advice: advice,
        category: category
      }
    end

    # 오행 기반 보조 해석
    def self.element_advice(dream_result, user_element)
      return "꿈에서 특별한 오행 기운을 찾지 못했어!" unless dream_result[:interpretations]&.any?

      dream_elements = dream_result[:interpretations].map { |i| i[:element] }
      most_common = dream_elements.group_by(&:itself).max_by { |_, v| v.size }&.first

      return "꿈에서 특별한 오행 기운을 찾지 못했어!" unless most_common

      if SajuEngine::FiveElements.generates?(user_element, most_common)
        "너의 #{user_element} 기운이 꿈의 #{most_common} 기운을 생(生)해줘! 꿈이 현실로 이어질 가능성이 높아요! 🌟"
      elsif SajuEngine::FiveElements.overcomes?(user_element, most_common)
        "너의 #{user_element} 기운이 꿈의 #{most_common} 기운을 극(剋)해. 꿈의 메시지를 잘 되새겨봐! 💪"
      elsif user_element == most_common
        "너의 #{user_element} 기운과 꿈의 #{most_common} 기운이 같아! 강력한 메시지야! ⭐"
      else
        "꿈의 #{most_common} 기운이 네게 새로운 에너지를 줄 수 있어! ✨"
      end
    end

    # 외부에서 호출 가능한 키워드 검색
    def self.find_keywords_public(text)
      find_keywords(text)
    end

    private

    def self.find_keywords(text)
      found = []
      DREAM_DB.each_key do |keyword|
        found << keyword if text.include?(keyword)
      end
      found.uniq
    end

    def self.generate_overall_message(score)
      case score
      when 90..100 then "대길! 🎊 최고의 꿈이야! 오늘 로또 사도 될 듯?"
      when 80..89 then "길몽! ✨ 좋은 일이 생길 징조야! 기대해봐!"
      when 70..79 then "괜찮은 꿈이야! 😊 평화로운 기운이 느껴져~"
      when 60..69 then "보통이야! 🙂 특별한 메시지는 없지만 무난한 하루가 될 거야."
      when 50..59 then "약간 주의! ⚡ 큰 걱정은 없지만 신중하게 행동하면 좋겠어."
      else "주의가 필요해! 💪 하지만 꿈은 경고의 메시지일 뿐이야. 준비하면 괜찮아!"
      end
    end
  end
end
