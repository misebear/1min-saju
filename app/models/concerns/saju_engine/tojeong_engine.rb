# 토정비결 엔진 — 전통 한국식 연간 운세
# 생년월일 기반 상괘·중괘·하괘 계산, 월별 운세
module SajuEngine
  module TojeongEngine
    extend self

    # 상괘 (년주 기반, 1~8)
    SANG_GWE = {
      1 => "건(乾)", 2 => "태(兌)", 3 => "이(離)", 4 => "진(震)",
      5 => "손(巽)", 6 => "감(坎)", 7 => "간(艮)", 8 => "곤(坤)"
    }

    # 월별 운세 해석 풀 (상중하 × 12월)
    MONTHLY_FORTUNES = {
      good: [
        "만사형통하니 적극적으로 추진하라",
        "귀인의 도움으로 큰 성과를 얻으리라",
        "재물이 들어와 넉넉한 달이 되리라",
        "새로운 인연이 찾아와 기쁨이 있으리라",
        "뜻한 바를 이루니 자신감을 가져라",
        "학업과 시험에 좋은 결과가 있으리라"
      ],
      normal: [
        "급하게 서두르지 말고 때를 기다려라",
        "작은 것에 감사하며 겸손하게 행동하라",
        "건강에 유의하되 크게 걱정할 것은 없으리라",
        "현재에 충실하면 좋은 일이 생기리라",
        "가까운 사람과의 소통을 게을리 하지 마라",
        "무리한 투자나 도전은 다음으로 미루어라"
      ],
      bad: [
        "구설수를 조심하고 언행을 삼가라",
        "이번 달은 참고 견디면 다음이 밝으리라",
        "재물 손실을 조심하고 절약하라",
        "건강관리에 각별히 신경 써라",
        "남과 다투지 말고 한 발 물러서라",
        "새로운 일보다 기존 일에 집중하라"
      ]
    }

    # 토정비결 분석
    def analyze(birth_date, hour = 11, gender = "남")
      year = birth_date.year
      month = birth_date.month
      day = birth_date.day

      # 상괘 (년 기반)
      sang = ((year + month) % 8) + 1
      # 중괘 (월 기반)
      jung = ((month + day) % 8) + 1
      # 하괘 (일+시 기반)
      ha = ((day + hour) % 8) + 1

      # 총운 점수 (0~100)
      seed = (year * 31 + month * 37 + day * 41 + hour * 43) % 100
      total_score = [seed + 20, 100].min

      # 총운 등급
      total_grade = case total_score
        when 80..100 then { text: "대길", emoji: "🎉", color: "#22c55e" }
        when 60..79 then { text: "길", emoji: "😊", color: "#3b82f6" }
        when 40..59 then { text: "평", emoji: "😐", color: "#f59e0b" }
        else { text: "흉→길", emoji: "💪", color: "#ef4444" }
      end

      # 12개월 운세
      monthly = (1..12).map do |m|
        m_seed = (year * 13 + month * 17 + day * 23 + m * 29) % 100
        m_score = [m_seed + 15, 100].min
        level = case m_score
          when 70..100 then :good
          when 40..69 then :normal
          else :bad
        end
        fortune_idx = (m_seed + m) % MONTHLY_FORTUNES[level].size
        {
          month: m,
          score: m_score,
          level: level,
          fortune: MONTHLY_FORTUNES[level][fortune_idx],
          emoji: case level; when :good then "☀️"; when :normal then "⛅"; else "🌧️"; end
        }
      end

      # 분야별 운세
      categories = {
        wealth: { emoji: "💰", name: "재물운", score: (seed * 7 + 13) % 40 + 50, advice: wealth_advice(seed) },
        love: { emoji: "💕", name: "애정운", score: (seed * 11 + 23) % 40 + 40, advice: love_advice(seed) },
        health: { emoji: "💪", name: "건강운", score: (seed * 13 + 31) % 40 + 45, advice: health_advice(seed) },
        career: { emoji: "💼", name: "직업운", score: (seed * 17 + 37) % 40 + 50, advice: career_advice(seed) },
        study: { emoji: "📚", name: "학업운", score: (seed * 19 + 41) % 40 + 40, advice: study_advice(seed) },
        travel: { emoji: "✈️", name: "이동운", score: (seed * 23 + 43) % 40 + 35, advice: travel_advice(seed) }
      }

      {
        sang_gwe: { num: sang, name: SANG_GWE[sang] },
        jung_gwe: { num: jung, name: SANG_GWE[jung] },
        ha_gwe: { num: ha, name: SANG_GWE[ha] },
        total_score: total_score,
        total_grade: total_grade,
        summary: total_summary(total_score, gender),
        monthly: monthly,
        categories: categories,
        year: year
      }
    end

    private

    def total_summary(score, gender)
      case score
      when 80..100 then "올해는 하늘이 도우니 만사형통! 큰 뜻을 품고 적극적으로 나아가라. 귀인의 도움이 있으니 인연을 소중히 하라."
      when 60..79 then "올해는 순탄하니 꾸준히 노력하면 좋은 결실을 맺으리라. 급하게 서두르지 말고 차근차근 쌓아가면 복이 오리라."
      when 40..59 then "올해는 평범하나 위기 속에 기회가 있으니 잘 살펴라. 건강과 인간관계에 신경 쓰고, 내실을 다지는 한 해로 삼으라."
      else "올해는 인내의 해이나 고진감래하리라. 어려움이 있더라도 포기하지 말고 버티면 하반기에 밝은 빛이 보이리라."
      end
    end

    def wealth_advice(s)
      ["큰 재물보다 작은 이익을 쌓아가라", "예상치 못한 수입이 있으니 기회를 놓치지 마라",
       "절약정신으로 재물을 지켜라", "동업이나 투자는 신중히 하라"][s % 4]
    end
    def love_advice(s)
      ["좋은 인연이 다가오니 마음을 열어라", "기존 관계를 더 소중히 가꾸는 해",
       "새로운 만남에서 운명의 상대를 만날 수 있으리라", "사랑에 솔직하면 행복이 찾아오리라"][s % 4]
    end
    def health_advice(s)
      ["규칙적인 운동으로 체력을 기르라", "과로를 피하고 충분한 휴식을 취하라",
       "식습관 개선이 건강의 열쇠", "정기 검진으로 건강을 챙겨라"][s % 4]
    end
    def career_advice(s)
      ["새로운 도전이 성과로 이어지리라", "현재 위치에서 실력을 쌓으면 인정받으리라",
       "이직이나 전직의 기회가 올 수 있으니 준비하라", "상사와의 관계를 잘 유지하라"][s % 4]
    end
    def study_advice(s)
      ["집중력이 높아지니 시험에 좋은 결과가 있으리라", "새로운 분야 학습에 도전하기 좋은 해",
       "꾸준한 복습이 합격의 비결이니라", "스터디 그룹이 큰 도움이 되리라"][s % 4]
    end
    def travel_advice(s)
      ["동쪽 방향으로의 이동이 길하다", "해외 여행에서 좋은 기운을 얻으리라",
       "이사는 하반기가 적합하니라", "가까운 곳의 여행이 마음의 안정을 주리라"][s % 4]
    end
  end
end
