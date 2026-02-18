# frozen_string_literal: true

module SajuEngine
  module SoloDestiny
    # 나는솔로 스타일 연애 아키타입 — 사주 오행 + 음양 기반
    ARCHETYPES = {
      "목_양" => {
        name: "영수형 🌳",
        title: "리더십 넘치는 든든한 사람",
        emoji: "🦁",
        desc: "곧고 당당한 큰 나무 같은 타입! 책임감이 강하고 리더십이 있어요. " \
              "연애에서도 주도적이고, 상대를 보호하려는 마음이 커요. " \
              "다만 가끔 고집이 세다는 소리를 들을 수 있으니 유연하게!",
        love_style: "먼저 고백하는 스타일, 진지하고 오래가는 연애를 원해요",
        ideal: "순수하고 유연한 사람, 자기 세계가 있으면서 나를 응원해주는 사람",
        solo_scenario: "첫 만남부터 눈에 띄는 존재감! 선택받는 것보다 직접 다가가는 편이에요. " \
                       "진심을 보여주면 상대도 결국 마음을 열게 되는 타입!"
      },
      "목_음" => {
        name: "정숙형 🌿",
        title: "유연하고 매력적인 4차원",
        emoji: "🦊",
        desc: "풀이나 넝쿨처럼 적응력이 뛰어나고, 어디서든 잘 어울려요. " \
              "겉으로는 부드럽지만 속은 단단한 반전 매력의 소유자! " \
              "눈치가 빠르고 분위기 파악을 잘 해요.",
        love_style: "은근히 다가가는 스타일, 자연스러운 스킨십을 좋아해요",
        ideal: "강하고 의지할 수 있는 사람, 내 유연함을 이해해주는 파트너",
        solo_scenario: "처음에는 조용하다가 점점 매력을 어필하는 타입! " \
                       "4차원적인 발언으로 웃음을 주다가 진심을 보여줘서 반전 매력 폭발!"
      },
      "화_양" => {
        name: "상철형 🔥",
        title: "열정 가득한 로맨티스트",
        emoji: "🦄",
        desc: "태양처럼 밝고 열정적인 타입! 에너지가 넘치고 주변을 환하게 해요. " \
              "연애에서는 온 마음을 다해 사랑하는 직진형이에요. " \
              "다만 감정 기복이 있을 수 있으니 주의!",
        love_style: "불같은 사랑, 매일 연락하고 매일 보고 싶은 타입",
        ideal: "내 열정을 받아줄 수 있는 넓은 마음의 소유자",
        solo_scenario: "등장부터 화제! 적극적으로 마음을 표현하고, " \
                       "이벤트도 서슴없이 하는 밀어붙이기형. 진심이 통하면 최고의 결말!"
      },
      "화_음" => {
        name: "현숙형 🕯️",
        title: "따뜻하고 지적인 감성파",
        emoji: "🦋",
        desc: "촛불처럼 은은하게 빛나는 타입! 감성적이고 섬세해서 상대의 마음을 잘 읽어요. " \
              "지적인 대화를 좋아하고, 깊이 있는 관계를 원해요.",
        love_style: "감성적인 대화를 중요시, 기념일과 편지를 소중히 여기는 타입",
        ideal: "지적이면서도 따뜻한 사람, 대화가 끊이지 않는 파트너",
        solo_scenario: "조용히 관찰하다가 마음에 드는 사람에게 깊은 대화로 다가가는 타입! " \
                       "첫인상보다 알수록 빠져드는 매력의 소유자."
      },
      "토_양" => {
        name: "광수형 🪨",
        title: "무뚝뚝하지만 진심인 사람",
        emoji: "🐻",
        desc: "산처럼 묵직하고 안정적인 타입! 말이 많지 않지만 행동으로 보여줘요. " \
              "한번 마음을 주면 쉽게 변하지 않는 진심형이에요. " \
              "신뢰와 안정을 중시해요.",
        love_style: "말보다 행동, 묵묵하게 챙기는 스타일",
        ideal: "내 진심을 알아봐주는 사람, 함께 있으면 편안한 파트너",
        solo_scenario: "첫인상은 무뚝뚝해 보이지만, 알고 보면 세심한 배려가 가득! " \
                       "데이트 장소, 선물 하나하나에 진심을 담아요. 반전 매력의 대명사!"
      },
      "토_음" => {
        name: "영숙형 🌾",
        title: "모성애 넘치는 따뜻한 사람",
        emoji: "🐰",
        desc: "들판처럼 넓고 포근한 타입! 상대를 감싸주고 보듬어주는 모성애가 있어요. " \
              "가정적이고 안정적인 관계를 원해요. " \
              "하지만 가끔은 자신을 위한 시간도 필요해요!",
        love_style: "상대를 챙기고 보살피는 것을 좋아하는 헌신형",
        ideal: "내 사랑을 감사히 받아줄 줄 아는 사람",
        solo_scenario: "처음부터 따뜻한 미소로 분위기를 부드럽게 만들어줘요. " \
                       "상대의 불편함을 먼저 캐치하고 챙기는 모습에 모두의 마음이 녹는 타입!"
      },
      "금_양" => {
        name: "철수형 ⚔️",
        title: "외유내강 카리스마형",
        emoji: "🐺",
        desc: "강철같은 의지와 결단력의 소유자! 겉으로는 쿨해 보이지만 속은 따뜻해요. " \
              "원칙이 있고 정의감이 강해서, 연애에서도 분명한 기준이 있어요.",
        love_style: "밀당보다는 확실한 표현, 좋으면 좋다고 말하는 직진형",
        ideal: "나의 원칙을 존중해주면서 서로 성장하는 파트너",
        solo_scenario: "처음에는 쿨한 포커페이스! 하지만 관심 있는 사람에게는 " \
                       "작은 것 하나까지 챙기며 의외의 다정함을 보여줘요."
      },
      "금_음" => {
        name: "순자형 💎",
        title: "직감으로 사랑하는 사람",
        emoji: "🐈",
        desc: "보석처럼 섬세하고 예리한 타입! 직감이 뛰어나서 상대의 진심을 잘 파악해요. " \
              "완벽을 추구하지만, 그만큼 자신에게도 깐깐해요.",
        love_style: "느낌이 오면 바로 아는 직감형, 깔끔한 연애를 좋아해요",
        ideal: "센스 있고 깨끗한 사람, 서로의 공간을 존중하는 파트너",
        solo_scenario: "첫 만남에서 이미 마음에 드는 사람을 정하는 타입! " \
                       "집중 공략하되 품위를 잃지 않는 깔끔한 어프로치로 상대 마음을 사로잡아요."
      },
      "수_양" => {
        name: "도훈형 🌊",
        title: "자유로운 영혼의 탐험가",
        emoji: "🦅",
        desc: "바다처럼 깊고 넓은 타입! 지적 호기심이 강하고 다양한 분야에 관심이 많아요. " \
              "자유를 사랑하지만, 진짜 사랑 앞에서는 올인하는 반전 매력!",
        love_style: "자유로운 연애를 좋아하지만, 진심이면 끝까지 가는 타입",
        ideal: "나의 자유를 존중하면서 함께 모험할 수 있는 파트너",
        solo_scenario: "독특한 매력으로 모두의 관심을 받지만, 쉽게 마음을 열지 않아요. " \
                       "하지만 결정하면 화끈하게 밀어붙이는 반전이 있어요!"
      },
      "수_음" => {
        name: "소영형 🌧️",
        title: "감성 충만한 공감 능력자",
        emoji: "🐬",
        desc: "이슬비처럼 부드럽고 감수성이 풍부한 타입! 상대의 감정을 잘 읽고 공감해줘요. " \
              "문학적이고 예술적인 감각이 있어요.",
        love_style: "감정을 깊이 나누는 연애, 대화와 공감이 중요해요",
        ideal: "함께 감성을 나눌 수 있는 예술적 감각의 파트너",
        solo_scenario: "조용하지만 깊은 눈빛으로 마음을 전달하는 타입! " \
                       "편지나 메시지로 진심을 전하면 상대가 감동받지 않을 수가 없어요."
      }
    }.freeze

    # 사주 분석으로 내 연애 아키타입 판별
    def self.analyze_archetype(saju)
      day_stem = saju[:day][:stem]
      element = HeavenlyStems.element(day_stem)
      yinyang = HeavenlyStems.yinyang(day_stem)
      yy = yinyang == "양" ? "양" : "음"

      key = "#{element}_#{yy}"
      ARCHETYPES[key] || ARCHETYPES["토_양"]  # fallback
    end

    # 이상적 궁합 상대 타입 추천
    def self.find_ideal_match(saju)
      day_element = HeavenlyStems.element(saju[:day][:stem])

      # 상생 관계의 오행이 가장 이상적
      ideal_elements = {
        "목" => [ "수", "화" ],  # 수→목 상생, 목→화 상생
        "화" => [ "목", "토" ],
        "토" => [ "화", "금" ],
        "금" => [ "토", "수" ],
        "수" => [ "금", "목" ]
      }

      matches = []
      (ideal_elements[day_element] || []).each do |el|
        [ "양", "음" ].each do |yy|
          key = "#{el}_#{yy}"
          arch = ARCHETYPES[key]
          matches << arch.merge(element: el, yinyang: yy, key: key) if arch
        end
      end

      matches
    end

    # 나는솔로 스타일 매칭 시나리오
    def self.solo_scenario(my_saju, match_key)
      my_arch = analyze_archetype(my_saju)
      match_arch = ARCHETYPES[match_key]
      return nil unless match_arch

      my_element = HeavenlyStems.element(my_saju[:day][:stem])
      match_element = match_key.split("_").first

      relation = element_relation(my_element, match_element)

      {
        my_type: my_arch,
        match_type: match_arch,
        relation: relation,
        story: generate_story(my_arch, match_arch, relation)
      }
    end

    # 오행 관계 판별
    def self.element_relation(el1, el2)
      sangsaeng = { "목" => "화", "화" => "토", "토" => "금", "금" => "수", "수" => "목" }
      sangguk = { "목" => "토", "화" => "금", "토" => "수", "금" => "목", "수" => "화" }

      if el1 == el2
        { type: "비화", label: "같은 오행 ⚖️", desc: "동질감이 강하지만 가끔 부딪힐 수 있어요" }
      elsif sangsaeng[el1] == el2
        { type: "상생_생", label: "상생(내가 생해줌) 🌱", desc: "내가 상대에게 에너지를 주는 관계예요" }
      elsif sangsaeng[el2] == el1
        { type: "상생_받", label: "상생(받는 쪽) 💝", desc: "상대가 나에게 힘을 주는 관계예요" }
      elsif sangguk[el1] == el2
        { type: "상극_극", label: "상극(내가 극함) ⚡", desc: "긴장감 있지만 성장을 이끄는 관계" }
      elsif sangguk[el2] == el1
        { type: "상극_받", label: "상극(받는 쪽) 💫", desc: "도전적이지만 변화를 가져오는 관계" }
      else
        { type: "기타", label: "특별한 관계 ✨", desc: "독특한 에너지의 조합이에요" }
      end
    end

    private_class_method def self.generate_story(my_arch, match_arch, relation)
      case relation[:type]
      when "상생_생"
        "#{my_arch[:name]}인 당신이 #{match_arch[:name]}을(를) 만나면? 🌟\n\n" \
        "당신의 에너지가 상대를 빛나게 해주는 아름다운 조합이에요! " \
        "나솔에서 이런 조합이 나오면 MC들이 '이건 진짜다!' 하고 소리칠 거예요 😆\n\n" \
        "💡 연애 팁: 너무 많이 퍼주지만 말고, 받는 것도 연습하세요!"
      when "상생_받"
        "#{my_arch[:name]}인 당신이 #{match_arch[:name]}을(를) 만나면? 💗\n\n" \
        "상대가 당신에게 힘을 주는 행복한 관계가 될 수 있어요! " \
        "나솔에서 만나면 자연스럽게 서로에게 끌리는 '운명적 조합'이에요 🥰\n\n" \
        "💡 연애 팁: 고마움을 자주 표현하면 관계가 더 깊어져요!"
      when "상극_극", "상극_받"
        "#{my_arch[:name]}인 당신이 #{match_arch[:name]}을(를) 만나면? ⚡\n\n" \
        "서로 다르기에 강하게 끌리는 케미 폭발 조합! " \
        "나솔에서 만나면 티격태격하다가 깊이 빠지는 '츤데레 로맨스' 가능성 200%! 🔥\n\n" \
        "💡 연애 팁: 차이를 인정하고 타협하는 연습이 핵심이에요!"
      when "비화"
        "#{my_arch[:name]}인 당신이 #{match_arch[:name]}을(를) 만나면? ⚖️\n\n" \
        "서로 너무 잘 알아서 편안하지만, 가끔 '너무 비슷해서' 지루할 수 있어요. " \
        "나솔에서 만나면 '우리 전생에 뭐였어?' 할 정도의 동질감! 😂\n\n" \
        "💡 연애 팁: 같이 새로운 경험을 하면서 다른 면을 발견해보세요!"
      else
        "#{my_arch[:name]}과 #{match_arch[:name]}의 만남은 특별한 케미를 만들어요! ✨\n\n" \
        "나솔에서 만나면 예측 불가능한 흥미진진한 전개가 펼쳐질 거예요!\n\n" \
        "💡 연애 팁: 열린 마음으로 상대를 알아가보세요!"
      end
    end
  end
end
