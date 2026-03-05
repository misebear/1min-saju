# 취업운/직업 적성 엔진 — 사주 기반 적성 분석
module SajuEngine
  module CareerEngine
    extend self

    # 오행별 적합 직업
    ELEMENT_CAREERS = {
      "목" => { field: "교육·미디어·패션", jobs: ["교사", "작가", "디자이너", "기자", "식물학자", "건축가", "환경운동가"],
                strengths: "창의력, 성장 마인드, 유연한 사고", color: "#22c55e" },
      "화" => { field: "엔터·마케팅·IT", jobs: ["연예인", "마케터", "개발자", "셰프", "소방관", "사진작가", "크리에이터"],
                strengths: "열정, 표현력, 추진력", color: "#ef4444" },
      "토" => { field: "부동산·농업·관리", jobs: ["공무원", "부동산중개사", "농업인", "회계사", "HR매니저", "사회복지사", "상담사"],
                strengths: "안정성, 신뢰, 책임감", color: "#f59e0b" },
      "금" => { field: "금융·법·기술", jobs: ["은행원", "변호사", "엔지니어", "의사", "군인", "경찰", "CEO"],
                strengths: "정확성, 결단력, 리더십", color: "#94a3b8" },
      "수" => { field: "연구·예술·무역", jobs: ["연구원", "예술가", "무역업", "외교관", "심리학자", "해양학자", "프리랜서"],
                strengths: "지혜, 적응력, 통찰력", color: "#3b82f6" }
    }

    # 십성별 업무 스타일
    TEN_GOD_STYLE = {
      "정관" => { style: "체계적 관리자", desc: "규칙과 질서를 중시. 공무원·관리직에 탁월", icon: "📋" },
      "편관" => { style: "혁신적 돌파자", desc: "기존 틀을 깨는 도전. 스타트업·군인에 적합", icon: "⚡" },
      "정인" => { style: "지식 전달자", desc: "배우고 가르치는 것을 좋아함. 교육·연구직 추천", icon: "📚" },
      "편인" => { style: "창의적 기획자", desc: "독특한 아이디어. 기획·디자인·예술 분야 추천", icon: "💡" },
      "비견" => { style: "협력적 실행자", desc: "팀워크 중시. 동업·파트너십 잘 어울림", icon: "🤝" },
      "겁재" => { style: "경쟁적 영업왕", desc: "경쟁에서 빛남. 영업·스포츠·투자 분야 추천", icon: "🔥" },
      "식신" => { style: "꼼꼼한 전문가", desc: "디테일에 강함. 요리·기술·전문직 추천", icon: "🍽️" },
      "상관" => { style: "자유로운 예술가", desc: "표현력 뛰어남. 엔터·프리랜서·강연가 추천", icon: "🎨" },
      "정재" => { style: "안정적 재테크", desc: "돈 관리에 뛰어남. 금융·회계·부동산 추천", icon: "💰" },
      "편재" => { style: "모험적 투자가", desc: "큰 돈을 다룸. 무역·주식·사업가 추천", icon: "🎯" }
    }

    def analyze(birth_date, hour = 11, gender = "남")
      analysis = SajuEngine.full_analysis(birth_date, hour, gender)
      saju = analysis[:saju]
      day_element = SajuEngine::HeavenlyStems.element(saju[:day][:stem])
      day_ten_god = analysis[:ten_gods][:month_stem] rescue "비견"

      career_info = ELEMENT_CAREERS[day_element] || ELEMENT_CAREERS["토"]
      style_info = TEN_GOD_STYLE[day_ten_god] || TEN_GOD_STYLE["비견"]

      # 취업 시기 분석
      seed = (birth_date.year * 31 + birth_date.month * 37 + birth_date.day * 41) % 100
      timing = career_timing(seed)

      # 연봉 운
      salary_luck = case (seed / 10) % 5
        when 0 then { text: "꾸준히 우상향", emoji: "📈", desc: "초반부터 안정적으로 연봉이 올라가는 타입이에요" }
        when 1 then { text: "후반 대폭발", emoji: "🚀", desc: "30대 후반~40대에 큰 도약이 있을 타입이에요" }
        when 2 then { text: "사업가형", emoji: "💎", desc: "월급보다 자기 사업에서 더 큰 돈을 벌 수 있어요" }
        when 3 then { text: "투잡 성공형", emoji: "🎯", desc: "본업 + 부업으로 수입을 극대화할 수 있어요" }
        else { text: "전문가형 고소득", emoji: "👨‍⚕️", desc: "전문 자격증·기술로 높은 연봉을 받을 타입이에요" }
      end

      {
        element: day_element,
        career_info: career_info,
        style_info: style_info,
        timing: timing,
        salary_luck: salary_luck,
        top3_jobs: career_info[:jobs].first(3),
        advice: career_advice(day_element, day_ten_god)
      }
    end

    private

    def career_timing(seed)
      best_month = ((seed * 3 + 7) % 12) + 1
      best_day = ["월요일", "화요일", "수요일", "목요일", "금요일"][seed % 5]
      {
        best_month: best_month,
        best_day: best_day,
        summary: "#{best_month}월이 취업/이직에 가장 유리한 시기예요. #{best_day}에 면접을 보면 좋은 결과가 있을 거예요!"
      }
    end

    def career_advice(element, ten_god)
      "당신의 #{element}(오행)의 에너지와 #{ten_god}의 업무 스타일이 결합되면 최고의 시너지를 낼 수 있어요. " \
      "자신만의 강점을 믿고, 꾸준히 실력을 쌓아가세요! 💪"
    end
  end
end
