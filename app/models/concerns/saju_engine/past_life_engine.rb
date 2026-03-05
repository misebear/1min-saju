# 전생운 엔진 — 생년월일 기반 전생 스토리
module SajuEngine
  module PastLifeEngine
    extend self

    ERAS = [
      { name: "고조선 시대", emoji: "🏔️", period: "BC 2333 ~ BC 108" },
      { name: "삼국시대 고구려", emoji: "⚔️", period: "BC 37 ~ AD 668" },
      { name: "삼국시대 백제", emoji: "🏛️", period: "BC 18 ~ AD 660" },
      { name: "삼국시대 신라", emoji: "👑", period: "BC 57 ~ AD 935" },
      { name: "고려시대", emoji: "📿", period: "918 ~ 1392" },
      { name: "조선 전기", emoji: "📜", period: "1392 ~ 1592" },
      { name: "조선 후기", emoji: "🎭", period: "1592 ~ 1897" },
      { name: "근대 개화기", emoji: "🚂", period: "1876 ~ 1945" },
      { name: "고대 이집트", emoji: "🏺", period: "BC 3000 ~ BC 30" },
      { name: "고대 그리스", emoji: "🏛️", period: "BC 800 ~ BC 146" },
      { name: "로마 제국", emoji: "🗡️", period: "BC 27 ~ AD 476" },
      { name: "중세 유럽", emoji: "🏰", period: "AD 500 ~ 1500" },
      { name: "르네상스 이탈리아", emoji: "🎨", period: "1400 ~ 1600" },
      { name: "에도 시대 일본", emoji: "⛩️", period: "1603 ~ 1868" },
      { name: "당나라 중국", emoji: "🐉", period: "618 ~ 907" }
    ]

    JOBS = [
      { name: "왕족/귀족", emoji: "👑", desc: "높은 지위에서 백성을 다스리며 부와 권력을 누렸습니다" },
      { name: "무사/장군", emoji: "⚔️", desc: "전장에서 용맹하게 싸우며 약자를 지키는 의로운 전사였습니다" },
      { name: "학자/선비", emoji: "📚", desc: "지식을 탐구하고 제자를 가르치며 진리를 추구했습니다" },
      { name: "예술가", emoji: "🎨", desc: "아름다움을 창조하며 세상에 감동을 선사했습니다" },
      { name: "의원/치유사", emoji: "🌿", desc: "아픈 이들을 치료하며 생명을 살리는 일에 헌신했습니다" },
      { name: "상인/무역가", emoji: "🪙", desc: "먼 곳을 오가며 물건을 교역하고 부를 쌓았습니다" },
      { name: "탐험가/항해사", emoji: "🧭", desc: "미지의 세계를 탐험하며 새로운 땅을 발견했습니다" },
      { name: "농부/자연인", emoji: "🌾", desc: "땅과 함께하며 자연의 섭리 속에서 소박하게 살았습니다" },
      { name: "승려/사제", emoji: "📿", desc: "영적 수행을 통해 깨달음을 추구하며 중생을 이끌었습니다" },
      { name: "음악가/시인", emoji: "🎵", desc: "아름다운 선율과 시로 사람들의 마음을 움직였습니다" },
      { name: "요리사/주막 주인", emoji: "🍲", desc: "맛있는 음식으로 사람들에게 행복을 대접했습니다" },
      { name: "점술가/무당", emoji: "🔮", desc: "하늘의 뜻을 읽고 사람들에게 길흉을 알려주었습니다" }
    ]

    KARMA_LESSONS = [
      "전생에서 권력을 쥐었기에, 이번 생에서는 겸손을 배우는 중입니다",
      "전생에서 사랑에 상처받았기에, 이번 생에서는 진정한 사랑을 찾을 수 있습니다",
      "전생에서 혼자 떠돌았기에, 이번 생에서는 소중한 인연을 만납니다",
      "전생에서 지식을 쌓았기에, 이번 생에서는 그 지혜가 빛을 발합니다",
      "전생에서 아름다움을 추구했기에, 이번 생에서도 예술적 감각이 뛰어납니다",
      "전생에서 용기를 보였기에, 이번 생에서는 리더로서 빛날 운명입니다",
      "전생에서 나눔을 실천했기에, 이번 생에서는 복이 돌아옵니다",
      "전생에서 치유의 능력이 있었기에, 이번 생에서도 사람들에게 위안이 됩니다"
    ]

    def analyze(birth_date, hour = 11, gender = "남")
      seed = (birth_date.year * 31 + birth_date.month * 37 + birth_date.day * 41 + hour * 43) % 10000

      era = ERAS[seed % ERAS.size]
      job = JOBS[(seed / 15) % JOBS.size]
      karma = KARMA_LESSONS[(seed / 100) % KARMA_LESSONS.size]

      # 전생 인연 관계
      connection = case (seed / 7) % 5
        when 0 then "전생에서 당신을 가장 아꼈던 사람이 이번 생에서도 가까이에 있어요 💕"
        when 1 then "전생에서의 라이벌이 이번 생에서는 가장 좋은 친구가 되었어요 🤝"
        when 2 then "전생에서 스승이었던 분이 이번 생에서 부모님으로 다시 만났어요 🙏"
        when 3 then "전생에서 함께 모험했던 동료가 이번 생에서 연인으로 왔어요 💘"
        else "전생에서 도와줬던 이가 이번 생에서 귀인이 되어 돌아올 거예요 ✨"
      end

      story = "#{era[:period]} #{era[:name]}에서 당신은 #{job[:name]}(으)로 살았습니다. #{job[:desc]}. 그때의 경험이 지금의 당신을 만들었어요."

      {
        era: era, job: job, story: story,
        karma: karma, connection: connection,
        past_personality: past_personality(seed),
        current_gift: current_gift(seed)
      }
    end

    private

    def past_personality(seed)
      traits = ["정의감이 강했던", "온화하고 자비로웠던", "지략이 뛰어났던",
                "예술적 감각이 빛났던", "용맹하고 대담했던", "지혜롭고 사려 깊었던",
                "유머 감각이 넘쳤던", "카리스마가 있었던"]
      traits[seed % traits.size]
    end

    def current_gift(seed)
      gifts = ["뛰어난 직감력 — 위험과 기회를 본능적으로 감지합니다",
               "치유의 에너지 — 주변 사람들의 마음을 편안하게 합니다",
               "창조적 능력 — 무에서 유를 만드는 재능이 있습니다",
               "리더십 — 사람들을 이끄는 자연스러운 카리스마가 있습니다",
               "학습 능력 — 무엇이든 빠르게 습득하는 재능이 있습니다",
               "공감 능력 — 다른 사람의 감정을 깊이 이해합니다"]
      gifts[seed % gifts.size]
    end
  end
end
