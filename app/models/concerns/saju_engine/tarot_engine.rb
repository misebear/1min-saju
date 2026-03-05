# 타로 엔진 — 메이저 아르카나 22장
module SajuEngine
  module TarotEngine
    extend self

    CARDS = [
      { id: 0, name: "바보", emoji: "🃏", upright: "새로운 시작, 무한한 가능성, 순수한 마음", reversed: "무모함, 방향 상실, 경솔한 결정" },
      { id: 1, name: "마법사", emoji: "🪄", upright: "의지력, 창조, 집중력, 능력 발휘", reversed: "속임수, 실력 부족, 자만심" },
      { id: 2, name: "여사제", emoji: "🌙", upright: "직감, 내면의 지혜, 신비, 인내", reversed: "비밀 폭로, 혼란, 얕은 판단" },
      { id: 3, name: "여제", emoji: "👑", upright: "풍요, 모성, 자연, 창조적 에너지", reversed: "의존, 과보호, 정체" },
      { id: 4, name: "황제", emoji: "🏛️", upright: "권위, 구조, 리더십, 안정", reversed: "독재, 경직, 권력 남용" },
      { id: 5, name: "교황", emoji: "📿", upright: "전통, 가르침, 신뢰, 정신적 지도", reversed: "독단, 맹목적 추종, 반항" },
      { id: 6, name: "연인", emoji: "💕", upright: "사랑, 조화, 선택, 가치관", reversed: "불화, 잘못된 선택, 유혹" },
      { id: 7, name: "전차", emoji: "⚡", upright: "승리, 전진, 의지, 결단력", reversed: "폭주, 통제 불능, 공격성" },
      { id: 8, name: "힘", emoji: "🦁", upright: "용기, 인내, 내면의 힘, 자제력", reversed: "나약함, 자기 의심, 분노" },
      { id: 9, name: "은둔자", emoji: "🏔️", upright: "내면 탐구, 고독, 지혜, 성찰", reversed: "고립, 외로움, 은둔" },
      { id: 10, name: "운명의 수레바퀴", emoji: "🎡", upright: "행운, 전환점, 운명, 변화", reversed: "불운, 저항, 통제 불가" },
      { id: 11, name: "정의", emoji: "⚖️", upright: "공정, 진실, 균형, 법칙", reversed: "불공정, 편견, 책임 회피" },
      { id: 12, name: "매달린 사람", emoji: "🙃", upright: "희생, 새로운 관점, 기다림", reversed: "무의미한 희생, 이기심" },
      { id: 13, name: "죽음", emoji: "🦋", upright: "끝과 시작, 변화, 재탄생", reversed: "변화 거부, 정체, 두려움" },
      { id: 14, name: "절제", emoji: "🌊", upright: "균형, 조화, 인내, 중용", reversed: "불균형, 과잉, 갈등" },
      { id: 15, name: "악마", emoji: "😈", upright: "유혹, 집착, 물질주의, 구속", reversed: "해방, 자유, 결단" },
      { id: 16, name: "탑", emoji: "⚡", upright: "갑작스런 변화, 파괴, 깨달음", reversed: "재건, 변화 회피, 위기 극복" },
      { id: 17, name: "별", emoji: "⭐", upright: "희망, 영감, 평화, 치유", reversed: "절망, 방향 상실, 불안" },
      { id: 18, name: "달", emoji: "🌕", upright: "환상, 직감, 무의식, 꿈", reversed: "혼란, 두려움, 기만" },
      { id: 19, name: "태양", emoji: "☀️", upright: "성공, 기쁨, 활력, 행복", reversed: "과시, 피로, 실패 가능성" },
      { id: 20, name: "심판", emoji: "📯", upright: "부활, 각성, 결산, 운명의 부름", reversed: "후회, 자기 비판, 무시" },
      { id: 21, name: "세계", emoji: "🌍", upright: "완성, 통합, 성취, 여행", reversed: "미완성, 지연, 부족함" }
    ]

    SPREADS = {
      three_card: { name: "과거·현재·미래", positions: ["과거", "현재", "미래"] },
      love: { name: "연애 타로", positions: ["나의 마음", "상대의 마음", "관계의 미래"] },
      career: { name: "커리어 타로", positions: ["현재 상황", "도전/기회", "결과"] }
    }

    # 타로 카드 뽑기 (결정론적: 날짜+주제 기반)
    def draw(birth_date, spread_type = :three_card, topic = "general")
      spread = SPREADS[spread_type] || SPREADS[:three_card]
      seed = (birth_date.year * 31 + birth_date.month * 37 + birth_date.day * 41 + Date.today.yday + topic.hash.abs) % 10000

      # 3장 뽑기 (중복 없이)
      drawn = []
      rng = seed
      3.times do
        loop do
          idx = rng % 22
          reversed = (rng / 22) % 3 == 0 # 33% 확률로 역방향
          card = CARDS[idx].merge(reversed: reversed)
          unless drawn.any? { |c| c[:id] == idx }
            drawn << card
            break
          end
          rng += 7
        end
        rng = (rng * 1103515245 + 12345) % (2**31)
      end

      reading = drawn.each_with_index.map do |card, i|
        {
          position: spread[:positions][i],
          card: card,
          meaning: card[:reversed] ? card[:reversed] : card[:upright],
          direction: card[:reversed] ? "역방향 🔄" : "정방향 ✨"
        }
      end

      overall = generate_overall(reading, spread_type)

      { spread: spread, cards: reading, overall: overall, spread_type: spread_type }
    end

    private

    def generate_overall(reading, type)
      positives = reading.count { |r| !r[:card][:reversed] }
      case positives
      when 3 then "세 장 모두 정방향! 현재 흐름이 매우 긍정적이에요. 자신감을 갖고 앞으로 나아가세요! 🌟"
      when 2 then "전반적으로 좋은 기운이 흐르고 있어요. 한 가지 조심할 점만 유의하면 좋은 결과가 있을 거예요! 😊"
      when 1 then "도전과 변화의 시기예요. 내면의 목소리에 귀 기울이고 신중하게 결정하세요. 💭"
      else "지금은 멈춰서 돌아볼 때예요. 서두르지 말고 내면을 정비하면 곧 좋은 기운이 찾아와요! 🙏"
      end
    end
  end
end
