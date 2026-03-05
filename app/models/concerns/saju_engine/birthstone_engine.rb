# 탄생석 엔진 — 월별 보석 + 의미 + 행운
module SajuEngine
  module BirthstoneEngine
    extend self

    STONES = {
      1 => { name: "가넷", emoji: "🔴", color: "#DC143C", meaning: "진실, 우정, 충실",
             desc: "가넷은 불같은 열정과 진실된 마음을 상징해요. 새해의 시작과 함께 새로운 결심을 지켜주는 수호석이에요.",
             luck: "진정한 친구를 만나고, 새로운 시작에 행운이 따릅니다", power: "에너지 충전, 자신감 회복" },
      2 => { name: "자수정", emoji: "💜", color: "#9966CC", meaning: "평화, 성실, 지혜",
             desc: "자수정은 마음의 평화와 영적 성장을 도와줘요. 스트레스를 해소하고 깊은 지혜를 얻게 해주는 돌이에요.",
             luck: "정신적 성장과 내면의 평화를 찾게 됩니다", power: "스트레스 해소, 직감력 강화" },
      3 => { name: "아쿠아마린", emoji: "💎", color: "#7FFFD4", meaning: "용기, 침착, 총명",
             desc: "아쿠아마린은 바다의 에너지를 담고 있어요. 두려움을 극복하고 소통 능력을 높여주는 보석이에요.",
             luck: "새로운 기회와 모험에서 행운이 따릅니다", power: "용기 부여, 커뮤니케이션 강화" },
      4 => { name: "다이아몬드", emoji: "💍", color: "#B9F2FF", meaning: "영원, 순수, 불멸",
             desc: "다이아몬드는 가장 강한 보석! 변치 않는 사랑과 성공의 상징이에요.",
             luck: "사랑과 성공 모두 손에 넣을 수 있습니다", power: "의지력 강화, 관계 수호" },
      5 => { name: "에메랄드", emoji: "💚", color: "#50C878", meaning: "행운, 행복, 재생",
             desc: "에메랄드는 클레오파트라가 사랑한 보석! 풍요와 재생의 에너지를 품고 있어요.",
             luck: "건강과 재물운이 함께 찾아옵니다", power: "치유, 풍요로움 유도" },
      6 => { name: "진주", emoji: "🫧", color: "#FDEEF4", meaning: "순결, 건강, 부",
             desc: "진주는 바다가 만든 기적! 고상한 기품과 건강을 지켜주는 보석이에요.",
             luck: "인간관계에서 신뢰와 존경을 얻게 됩니다", power: "품격 향상, 건강 수호" },
      7 => { name: "루비", emoji: "❤️", color: "#E0115F", meaning: "열정, 사랑, 용기",
             desc: "루비는 보석의 왕! 뜨거운 열정과 용기를 불어넣어주는 강력한 에너지의 보석이에요.",
             luck: "리더십을 발휘할 기회가 찾아옵니다", power: "열정 불꽃, 카리스마 강화" },
      8 => { name: "페리도트", emoji: "💛", color: "#B4C424", meaning: "부부의 행복, 지혜",
             desc: "페리도트는 태양의 보석! 밝은 에너지로 우울함을 날려주고 행복을 불러와요.",
             luck: "가정에 행복이 가득하고 재물이 들어옵니다", power: "긍정 에너지, 관계 회복" },
      9 => { name: "사파이어", emoji: "💙", color: "#0F52BA", meaning: "성실, 진실, 덕망",
             desc: "사파이어는 하늘의 보석! 진실함과 지혜를 상징하며, 마음의 평정을 유지하게 해줘요.",
             luck: "진실한 관계와 학업/업무 성과를 얻게 됩니다", power: "집중력 강화, 진실 수호" },
      10 => { name: "오팔", emoji: "🌈", color: "#A8C3BC", meaning: "희망, 순결, 창조",
              desc: "오팔은 무지개빛 보석! 창의력과 상상력을 극대화하고 행운을 가져다줘요.",
              luck: "예상치 못한 행운과 기회가 찾아옵니다", power: "창의력 폭발, 행운 유도" },
      11 => { name: "토파즈", emoji: "🧡", color: "#FFC87C", meaning: "우정, 잠재력, 희망",
              desc: "토파즈는 따뜻한 기운의 보석! 우정을 깊게 하고 잠재된 능력을 꺼내줘요.",
              luck: "숨겨진 재능이 발견되고 인정받게 됩니다", power: "잠재력 각성, 우정 강화" },
      12 => { name: "탄자나이트", emoji: "💎", color: "#0072BB", meaning: "성공, 기품, 영감",
              desc: "탄자나이트는 변신의 보석! 빛에 따라 색이 변하듯 당신의 무한한 가능성을 상징해요.",
              luck: "한 해를 마무리하며 큰 성과를 거둡니다", power: "변화 적응, 성공 견인" }
    }

    def analyze(birth_date)
      month = birth_date.month
      stone = STONES[month]

      # 행운의 숫자 (탄생석 기반)
      seed = birth_date.year * 31 + birth_date.month * 37 + birth_date.day * 41
      lucky_numbers = 3.times.map { |i| ((seed * (i + 3) + 7) % 45) + 1 }.uniq.sort.first(3)

      # 궁합이 좋은 탄생석
      partner_month = ((month + 5) % 12) + 1
      partner_stone = STONES[partner_month]

      {
        stone: stone,
        month: month,
        lucky_numbers: lucky_numbers,
        partner_stone: partner_stone,
        partner_month: partner_month,
        zodiac_match: zodiac_match(month)
      }
    end

    private

    def zodiac_match(month)
      matches = {
        1 => "물병자리 ♒", 2 => "물고기자리 ♓", 3 => "양자리 ♈",
        4 => "황소자리 ♉", 5 => "쌍둥이자리 ♊", 6 => "게자리 ♋",
        7 => "사자자리 ♌", 8 => "처녀자리 ♍", 9 => "천칭자리 ♎",
        10 => "전갈자리 ♏", 11 => "사수자리 ♐", 12 => "염소자리 ♑"
      }
      matches[month]
    end
  end
end
