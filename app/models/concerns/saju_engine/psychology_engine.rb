# 심리풀이 엔진 — 4문항 심리 테스트
module SajuEngine
  module PsychologyEngine
    extend self

    QUESTIONS = [
      {
        id: 1, emoji: "🌲",
        text: "숲속을 걷고 있어. 갑자기 길이 두 갈래로 나뉘었어!",
        options: [
          { key: "A", text: "🌞 밝고 넓은 길로 간다", trait: :extrovert },
          { key: "B", text: "🌿 좁지만 신비로운 길로 간다", trait: :introvert }
        ]
      },
      {
        id: 2, emoji: "🏠",
        text: "꿈속에서 빈 집을 발견했어. 어떤 방에 먼저 들어갈래?",
        options: [
          { key: "A", text: "📚 책으로 가득한 서재", trait: :thinking },
          { key: "B", text: "🎨 그림이 걸린 아트룸", trait: :feeling }
        ]
      },
      {
        id: 3, emoji: "🎁",
        text: "누군가 선물 상자를 줬어. 어떻게 열어볼래?",
        options: [
          { key: "A", text: "📦 리본을 풀고 조심스럽게", trait: :judging },
          { key: "B", text: "💥 빨리 뜯어서 확인한다", trait: :perceiving }
        ]
      },
      {
        id: 4, emoji: "⏰",
        text: "친구와 약속 시간이 1시간 남았어!",
        options: [
          { key: "A", text: "📋 미리 가서 주변을 탐색한다", trait: :sensing },
          { key: "B", text: "💭 가면서 오늘 뭐 할지 상상한다", trait: :intuition }
        ]
      }
    ]

    TYPES = {
      # 16가지 조합
      "extrovert_thinking_judging_sensing" => { name: "🦁 리더형 사자", desc: "당신은 타고난 리더! 결단력 있고 현실적이며, 목표를 향해 돌진하는 추진력의 소유자입니다.", color: "#ef4444", advice: "가끔은 다른 사람의 의견도 들어보세요. 공감 능력을 키우면 더 훌륭한 리더가 됩니다." },
      "extrovert_thinking_judging_intuition" => { name: "🦅 전략가형 독수리", desc: "넓은 시야로 큰 그림을 보는 전략가! 논리적이면서 직관적이어서 남들이 못 보는 기회를 포착합니다.", color: "#8b5cf6", advice: "세부사항도 놓치지 마세요. 큰 계획 속 작은 디테일이 성패를 가릅니다." },
      "extrovert_thinking_perceiving_sensing" => { name: "🐺 모험가형 늑대", desc: "행동파! 머릿속 계획보다 직접 부딪히며 배우는 스타일입니다. 에너지 넘치고 적응력이 뛰어나요.", color: "#f97316", advice: "때로는 멈춰서 계획을 세워보세요. 효율이 배가 됩니다." },
      "extrovert_thinking_perceiving_intuition" => { name: "🦊 발명가형 여우", desc: "창의적 문제 해결사! 기존 틀을 깨고 새로운 방법을 찾아내는 천재형 두뇌의 소유자.", color: "#06b6d4", advice: "아이디어를 실행으로 옮기는 끈기를 길러보세요." },
      "extrovert_feeling_judging_sensing" => { name: "🐕 수호자형 강아지", desc: "따뜻하고 헌신적! 주변 사람들을 챙기고 조직의 화합을 이끄는 사교의 달인.", color: "#22c55e", advice: "자기 자신도 챙기세요. 남을 돕는 것도 좋지만 내 에너지도 중요합니다." },
      "extrovert_feeling_judging_intuition" => { name: "🦋 영감형 나비", desc: "사람들에게 영감을 주는 카리스마! 감정과 직관으로 세상을 변화시키는 이상주의자.", color: "#ec4899", advice: "현실과 이상의 균형을 찾으세요. 작은 것부터 실천해 보세요." },
      "extrovert_feeling_perceiving_sensing" => { name: "🐬 자유영혼 돌고래", desc: "Fun하고 사교적! 지금 이 순간을 즐기며 주변에 웃음을 전파하는 에너자이저.", color: "#3b82f6", advice: "장기적인 목표도 세워보세요. 즐거움 속에 성장이 있습니다." },
      "extrovert_feeling_perceiving_intuition" => { name: "🦄 몽상가형 유니콘", desc: "상상력의 끝판왕! 세상을 아름답게 보고 예술적 감성으로 주변을 감동시킵니다.", color: "#a855f7", advice: "상상을 현실로! 작은 프로젝트라도 완성해 보세요." },
      "introvert_thinking_judging_sensing" => { name: "🦉 분석가형 올빼미", desc: "냉철한 분석가! 데이터와 논리로 정확한 판단을 내리는 완벽주의자.", color: "#475569", advice: "완벽하지 않아도 괜찮아요. 때로는 그냥 시작하는 용기도 필요합니다." },
      "introvert_thinking_judging_intuition" => { name: "🐈 전략가형 고양이", desc: "조용하지만 강한! 혼자만의 세계에서 깊은 사고로 천재적 아이디어를 만드는 타입.", color: "#6366f1", advice: "생각한 것을 밖으로 표현해 보세요. 세상이 당신의 아이디어를 기다립니다." },
      "introvert_thinking_perceiving_sensing" => { name: "🐨 장인형 코알라", desc: "묵묵히 자기 일을 하는 장인! 손재주와 실용적 능력이 뛰어난 실력파.", color: "#78716c", advice: "혼자 하는 것도 좋지만 협업의 힘도 경험해 보세요." },
      "introvert_thinking_perceiving_intuition" => { name: "🦇 탐구자형 박쥐", desc: "미지의 세계를 탐구하는 지적 호기심의 화신! 남들이 관심 없는 분야에서 보석을 찾아냅니다.", color: "#7c3aed", advice: "탐구 결과를 정리하고 공유해 보세요. 숨은 가치가 빛날 거예요." },
      "introvert_feeling_judging_sensing" => { name: "🐢 현자형 거북이", desc: "느리지만 확실한! 깊은 공감 능력으로 신뢰를 쌓고, 묵묵히 자기 길을 가는 성실파.", color: "#059669", advice: "더 넓은 세상을 경험해 보세요. 편안한 영역 밖에서 성장합니다." },
      "introvert_feeling_judging_intuition" => { name: "🐇 이상주의형 토끼", desc: "세상을 더 좋은 곳으로 만들고 싶은 순수한 영혼! 깊은 감성과 통찰력의 소유자.", color: "#db2777", advice: "완벽한 세상은 없어요. 할 수 있는 것부터 시작하세요." },
      "introvert_feeling_perceiving_sensing" => { name: "🐼 힐러형 판다", desc: "조용히 곁에서 치유해주는 존재! 자연을 사랑하고 평화를 추구하는 온화한 영혼.", color: "#14b8a6", advice: "가끔은 자기 의견을 당당하게 말해보세요." },
      "introvert_feeling_perceiving_intuition" => { name: "🦌 시인형 사슴", desc: "세상을 시처럼 느끼는 감성의 소유자! 예술적 감각이 뛰어나고 깊은 내면의 세계를 가지고 있어요.", color: "#d946ef", advice: "감성을 글이나 그림으로 표현해 보세요. 공감하는 사람이 많을 거예요." }
    }

    def questions
      QUESTIONS
    end

    def analyze(answers)
      # answers = ["A", "B", "A", "B"] (4개)
      traits = []
      QUESTIONS.each_with_index do |q, i|
        answer = answers[i]&.upcase || "A"
        option = q[:options].find { |o| o[:key] == answer } || q[:options][0]
        traits << option[:trait].to_s
      end

      type_key = traits.join("_")
      result = TYPES[type_key] || TYPES.values.first

      { traits: traits, type_key: type_key, result: result, questions: QUESTIONS, answers: answers }
    end
  end
end
