# frozen_string_literal: true

module SajuEngine
  module ZodiacEngine
    # 12별자리 정보
    ZODIAC_SIGNS = {
      "물병자리" => { range: [ [ 1, 20 ], [ 2, 18 ] ], emoji: "♒", element: "공기", planet: "천왕성", color: "#42A5F5",
                     traits: "독창적이고 진보적! 자유와 혁신을 사랑하는 타입이에요.",
                     love: "지적인 대화가 통하는 사람에게 끌려요. 독립적인 관계를 원해요.",
                     career: "IT, 과학, 사회운동, 혁신 분야에서 빛을 발해요." },
      "물고기자리" => { range: [ [ 2, 19 ], [ 3, 20 ] ], emoji: "♓", element: "물", planet: "해왕성", color: "#7E57C2",
                      traits: "감성적이고 직감이 뛰어나! 예술적 감각이 풍부한 타입이에요.",
                      love: "로맨틱한 사랑을 꿈꿔요. 감정적 교류가 중요해요.",
                      career: "예술, 음악, 심리, 치유 분야에서 재능을 발휘해요." },
      "양자리" => { range: [ [ 3, 21 ], [ 4, 19 ] ], emoji: "♈", element: "불", planet: "화성", color: "#EF5350",
                   traits: "용감하고 열정적! 도전을 즐기는 개척자 타입이에요.",
                   love: "적극적으로 사랑을 표현해요. 첫눈에 반하는 스타일!",
                   career: "스타트업, 스포츠, 군인, 리더 역할에서 빛을 발해요." },
      "황소자리" => { range: [ [ 4, 20 ], [ 5, 20 ] ], emoji: "♉", element: "땅", planet: "금성", color: "#66BB6A",
                    traits: "안정적이고 실용적! 감각적인 즐거움을 사랑하는 타입이에요.",
                    love: "한번 마음을 주면 끝까지! 안정적인 관계를 원해요.",
                    career: "금융, 요리, 음악, 부동산 분야에서 뛰어난 능력을 발휘해요." },
      "쌍둥이자리" => { range: [ [ 5, 21 ], [ 6, 21 ] ], emoji: "♊", element: "공기", planet: "수성", color: "#FFA726",
                      traits: "재치있고 다재다능! 호기심이 왕성한 소통의 달인이에요.",
                      love: "대화가 통하는 사람이 최고! 지루한 건 참을 수 없어요.",
                      career: "미디어, 작가, 마케팅, 교육 분야에서 재능을 발휘해요." },
      "게자리" => { range: [ [ 6, 22 ], [ 7, 22 ] ], emoji: "♋", element: "물", planet: "달", color: "#B0BEC5",
                   traits: "따뜻하고 보호적! 가정적이고 감정이 풍부한 타입이에요.",
                   love: "가족 같은 따뜻한 사랑을 원해요. 헌신적인 파트너!",
                   career: "요리, 간호, 교육, 상담 분야에서 빛을 발해요." },
      "사자자리" => { range: [ [ 7, 23 ], [ 8, 22 ] ], emoji: "♌", element: "불", planet: "태양", color: "#FFD54F",
                    traits: "카리스마 넘치고 자신감 폭발! 무대 위의 왕/여왕이에요.",
                    love: "화려하고 드라마틱한 사랑! 존중받는 게 중요해요.",
                    career: "연예, 경영, 디자인, 정치 분야에서 리더십을 발휘해요." },
      "처녀자리" => { range: [ [ 8, 23 ], [ 9, 22 ] ], emoji: "♍", element: "땅", planet: "수성", color: "#8D6E63",
                    traits: "꼼꼼하고 분석적! 완벽주의자이면서도 따뜻한 마음을 가졌어요.",
                    love: "작은 배려에 감동받아요. 진정성 있는 사랑을 원해요.",
                    career: "의료, 연구, 편집, 데이터 분석 분야에서 뛰어나요." },
      "천칭자리" => { range: [ [ 9, 23 ], [ 10, 23 ] ], emoji: "♎", element: "공기", planet: "금성", color: "#EC407A",
                    traits: "균형 잡히고 우아해! 조화와 아름다움을 추구하는 타입이에요.",
                    love: "공평하고 아름다운 관계를 원해요. 로맨틱한 분위기를 좋아해요.",
                    career: "법률, 디자인, 외교, 예술 분야에서 재능을 발휘해요." },
      "전갈자리" => { range: [ [ 10, 24 ], [ 11, 21 ] ], emoji: "♏", element: "물", planet: "명왕성", color: "#880E4F",
                    traits: "강렬하고 열정적! 깊은 통찰력을 가진 신비로운 타입이에요.",
                    love: "깊고 강렬한 사랑! 올인하는 스타일이에요.",
                    career: "수사, 심리, 연구, 금융 투자 분야에서 빛을 발해요." },
      "사수자리" => { range: [ [ 11, 22 ], [ 12, 21 ] ], emoji: "♐", element: "불", planet: "목성", color: "#9C27B0",
                    traits: "자유롭고 낙천적! 모험과 여행을 사랑하는 철학자 타입이에요.",
                    love: "함께 모험할 수 있는 파트너를 원해요. 속박은 싫어!",
                    career: "여행, 교육, 출판, 철학 분야에서 행복을 찾아요." },
      "염소자리" => { range: [ [ 12, 22 ], [ 1, 19 ] ], emoji: "♑", element: "땅", planet: "토성", color: "#455A64",
                    traits: "야심차고 책임감 강해! 목표를 향해 꾸준히 나아가는 타입이에요.",
                    love: "진지하고 안정적인 관계를 원해요. 장기적 관점으로 봐요.",
                    career: "경영, 정치, 건축, 행정 분야에서 높은 성과를 내요." }
    }.freeze

    # 생일 → 별자리 판별
    def self.find_sign(month, day)
      ZODIAC_SIGNS.each do |name, info|
        start_m, start_d = info[:range][0]
        end_m, end_d = info[:range][1]

        if start_m == end_m
          return name if month == start_m && day >= start_d && day <= end_d
        elsif start_m > end_m # 염소자리처럼 연도를 넘기는 경우
          return name if (month == start_m && day >= start_d) || (month == end_m && day <= end_d)
        else
          return name if (month == start_m && day >= start_d) || (month == end_m && day <= end_d)
        end
      end
      "물병자리" # 기본값
    end

    # 오늘의 별자리 운세 생성 (결정적 — 날짜/별자리 기반)
    def self.daily_fortune(sign_name, date = Date.today)
      sign = ZODIAC_SIGNS[sign_name]
      return nil unless sign

      # 일관된 랜덤값 생성 (날짜+별자리 해시 기반)
      seed = (date.to_s + sign_name).bytes.sum
      rng = Random.new(seed)

      score = rng.rand(55..98)
      mood_options = %w[최고 좋음 보통 평화 활발 신비]
      mood = mood_options[rng.rand(mood_options.size)]

      lucky_colors = %w[빨간색 파란색 노란색 초록색 보라색 분홍색 하늘색 주황색 흰색]
      lucky_color = lucky_colors[rng.rand(lucky_colors.size)]
      lucky_number = rng.rand(1..45)

      compatibility_signs = ZODIAC_SIGNS.keys.reject { |s| s == sign_name }
      best_match = compatibility_signs[rng.rand(compatibility_signs.size)]

      advice_pool = fortune_advice_pool(sign[:element])
      advice = advice_pool[rng.rand(advice_pool.size)]

      love_pool = love_advice_pool(sign[:element])
      love_advice = love_pool[rng.rand(love_pool.size)]

      career_pool = career_advice_pool(sign[:element])
      career_advice = career_pool[rng.rand(career_pool.size)]

      {
        sign: sign_name,
        info: sign,
        score: score,
        mood: mood,
        lucky_color: lucky_color,
        lucky_number: lucky_number,
        best_match: best_match,
        advice: advice,
        love_advice: love_advice,
        career_advice: career_advice,
        date: date
      }
    end

    # 별자리 궁합
    def self.compatibility(sign1, sign2)
      info1 = ZODIAC_SIGNS[sign1]
      info2 = ZODIAC_SIGNS[sign2]
      return nil unless info1 && info2

      # 원소 궁합
      element_compat = {
        %w[불 불] => 85, %w[불 공기] => 90, %w[불 땅] => 60, %w[불 물] => 50,
        %w[공기 공기] => 80, %w[공기 땅] => 55, %w[공기 물] => 65,
        %w[땅 땅] => 75, %w[땅 물] => 85,
        %w[물 물] => 80
      }

      pair = [ info1[:element], info2[:element] ].sort
      score = element_compat[pair] || element_compat[pair.reverse] || 70

      {
        sign1: sign1, sign2: sign2,
        score: score,
        message: compatibility_message(score)
      }
    end

    private

    def self.fortune_advice_pool(element)
      case element
      when "불"
        [ "열정을 살려서 적극적으로 행동하면 좋은 결과가 있을 거야!",
         "에너지가 넘치는 하루! 새로운 도전을 시작해봐.",
         "오늘은 리더십을 발휘할 수 있는 날이야. 자신감을 가져!",
         "과감한 결정이 좋은 결과를 가져올 수 있어!" ]
      when "땅"
        [ "차분하고 실용적으로 접근하면 성과가 있을 거야!",
         "꾸준함이 빛나는 하루! 기존 계획을 착실히 실행해봐.",
         "재무적인 결정을 내리기 좋은 날이야. 안정이 핵심!",
         "작은 것부터 하나씩! 성실함이 빛을 발할 거야." ]
      when "공기"
        [ "소통이 핵심인 하루! 주변 사람들과 이야기를 나눠봐.",
         "새로운 아이디어가 떠오를 수 있어. 메모해두는 것 추천!",
         "네트워킹에 좋은 날! 새로운 인맥이 행운을 가져올 수 있어.",
         "유연한 사고가 문제를 해결할 열쇠야!" ]
      when "물"
        [ "직감을 믿어봐! 오늘은 감성이 빛나는 날이야.",
         "내면의 목소리에 귀를 기울여봐. 중요한 메시지가 있을 수 있어.",
         "감정적인 교류가 깊어지는 하루. 진심으로 대화해봐.",
         "창의적인 활동에 몰입하면 좋은 결과가 있을 거야!" ]
      else
        [ "오늘도 좋은 하루! 긍정적인 마음으로 시작해봐. ✨" ]
      end
    end

    def self.love_advice_pool(element)
      case element
      when "불" then [ "적극적으로 마음을 표현해봐! 열정이 통할 수 있어.", "새로운 만남에 열려있는 자세가 좋아.", "함께 모험을 떠나보는 건 어때?" ]
      when "땅" then [ "진정성 있는 대화가 관계를 깊게 해줄 거야.", "작은 선물이나 배려가 큰 감동을 줄 수 있어.", "안정적인 만남을 추구하면 좋아." ]
      when "공기" then [ "재치있는 대화로 호감을 사는 건 어때?", "가벼운 약속이 좋은 인연으로 이어질 수 있어.", "SNS에서 좋은 만남이 있을 수도!" ]
      when "물" then [ "진심 어린 감정 표현이 상대의 마음을 움직일 거야.", "로맨틱한 분위기를 연출해봐.", "감정에 솔직해지는 게 중요해." ]
      else [ "사랑은 용기야! 마음을 열어봐. 💕" ]
      end
    end

    def self.career_advice_pool(element)
      case element
      when "불" then [ "과감한 프로젝트를 추진해봐!", "리더 역할을 맡으면 좋은 성과가 있을 거야.", "새로운 아이디어를 제안해봐." ]
      when "땅" then [ "꼼꼼한 계획이 성공의 열쇠야!", "기존 프로젝트를 완성도 높게 마무리하면 인정받을 거야.", "재무 관리에 신경 쓰면 좋아." ]
      when "공기" then [ "팀워크와 소통이 중요한 날이야!", "프레젠테이션이나 발표에서 빛날 수 있어.", "새로운 인맥이 기회를 열어줄 수 있어." ]
      when "물" then [ "창의적인 업무에서 성과가 날 수 있어!", "동료의 감정에 공감하면 좋은 관계를 쌓을 수 있어.", "직감을 믿고 결정해봐." ]
      else [ "오늘의 업무를 차근차근 처리하면 좋아! 💼" ]
      end
    end

    def self.compatibility_message(score)
      case score
      when 85..100 then "환상의 궁합! 서로를 잘 이해하고 보완하는 최고의 조합이에요. 💕"
      when 70..84 then "좋은 궁합! 서로의 장점을 살리면 함께 성장할 수 있어요. 😊"
      when 55..69 then "보통 궁합. 서로의 차이를 인정하고 노력하면 잘 맞을 수 있어요. 🤝"
      else "도전적인 궁합! 하지만 다름이 매력이 될 수 있어요. 서로 배울 점이 많아! 💪"
      end
    end
  end
end
