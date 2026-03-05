# 타로 엔진 v2 — 메이저 아르카나 22장 + 마이너 아르카나 56장 = 78장
module SajuEngine
  module TarotEngine
    extend self

    # ===== 메이저 아르카나 (0~21) =====
    MAJOR_ARCANA = [
      { id: 0,  name: "바보",           en: "The Fool",            emoji: "🃏", suit: "major", upright: "새로운 시작, 무한한 가능성, 순수한 마음", reversed: "무모함, 방향 상실, 경솔한 결정" },
      { id: 1,  name: "마법사",         en: "The Magician",        emoji: "🪄", suit: "major", upright: "의지력, 창조, 집중력, 능력 발휘", reversed: "속임수, 실력 부족, 자만심" },
      { id: 2,  name: "여사제",         en: "The High Priestess",  emoji: "🌙", suit: "major", upright: "직감, 내면의 지혜, 신비, 인내", reversed: "비밀 폭로, 혼란, 얕은 판단" },
      { id: 3,  name: "여제",           en: "The Empress",         emoji: "👑", suit: "major", upright: "풍요, 모성, 자연, 창조적 에너지", reversed: "의존, 과보호, 정체" },
      { id: 4,  name: "황제",           en: "The Emperor",         emoji: "🏛️", suit: "major", upright: "권위, 구조, 리더십, 안정", reversed: "독재, 경직, 권력 남용" },
      { id: 5,  name: "교황",           en: "The Hierophant",      emoji: "📿", suit: "major", upright: "전통, 가르침, 신뢰, 정신적 지도", reversed: "독단, 맹목적 추종, 반항" },
      { id: 6,  name: "연인",           en: "The Lovers",          emoji: "💕", suit: "major", upright: "사랑, 조화, 선택, 가치관", reversed: "불화, 잘못된 선택, 유혹" },
      { id: 7,  name: "전차",           en: "The Chariot",         emoji: "⚡", suit: "major", upright: "승리, 전진, 의지, 결단력", reversed: "폭주, 통제 불능, 공격성" },
      { id: 8,  name: "힘",             en: "Strength",            emoji: "🦁", suit: "major", upright: "용기, 인내, 내면의 힘, 자제력", reversed: "나약함, 자기 의심, 분노" },
      { id: 9,  name: "은둔자",         en: "The Hermit",          emoji: "🏔️", suit: "major", upright: "내면 탐구, 고독, 지혜, 성찰", reversed: "고립, 외로움, 은둔" },
      { id: 10, name: "운명의 수레바퀴", en: "Wheel of Fortune",    emoji: "🎡", suit: "major", upright: "행운, 전환점, 운명, 변화", reversed: "불운, 저항, 통제 불가" },
      { id: 11, name: "정의",           en: "Justice",             emoji: "⚖️", suit: "major", upright: "공정, 진실, 균형, 법칙", reversed: "불공정, 편견, 책임 회피" },
      { id: 12, name: "매달린 사람",    en: "The Hanged Man",      emoji: "🙃", suit: "major", upright: "희생, 새로운 관점, 기다림", reversed: "무의미한 희생, 이기심" },
      { id: 13, name: "죽음",           en: "Death",               emoji: "🦋", suit: "major", upright: "끝과 시작, 변화, 재탄생", reversed: "변화 거부, 정체, 두려움" },
      { id: 14, name: "절제",           en: "Temperance",          emoji: "🌊", suit: "major", upright: "균형, 조화, 인내, 중용", reversed: "불균형, 과잉, 갈등" },
      { id: 15, name: "악마",           en: "The Devil",           emoji: "😈", suit: "major", upright: "유혹, 집착, 물질주의, 구속", reversed: "해방, 자유, 결단" },
      { id: 16, name: "탑",             en: "The Tower",           emoji: "💥", suit: "major", upright: "갑작스런 변화, 파괴, 깨달음", reversed: "재건, 변화 회피, 위기 극복" },
      { id: 17, name: "별",             en: "The Star",            emoji: "⭐", suit: "major", upright: "희망, 영감, 평화, 치유", reversed: "절망, 방향 상실, 불안" },
      { id: 18, name: "달",             en: "The Moon",            emoji: "🌕", suit: "major", upright: "환상, 직감, 무의식, 꿈", reversed: "혼란, 두려움, 기만" },
      { id: 19, name: "태양",           en: "The Sun",             emoji: "☀️", suit: "major", upright: "성공, 기쁨, 활력, 행복", reversed: "과시, 피로, 실패 가능성" },
      { id: 20, name: "심판",           en: "Judgement",           emoji: "📯", suit: "major", upright: "부활, 각성, 결산, 운명의 부름", reversed: "후회, 자기 비판, 무시" },
      { id: 21, name: "세계",           en: "The World",           emoji: "🌍", suit: "major", upright: "완성, 통합, 성취, 여행", reversed: "미완성, 지연, 부족함" }
    ].freeze

    # ===== 마이너 아르카나 (56장) =====
    SUIT_INFO = {
      wands:    { name: "완드",    emoji: "🔥", element: "불", theme: "열정, 창의력, 행동" },
      cups:     { name: "컵",      emoji: "💧", element: "물", theme: "감정, 사랑, 관계" },
      swords:   { name: "검",      emoji: "⚔️", element: "바람", theme: "지성, 갈등, 진실" },
      pentacles:{ name: "동전",    emoji: "💰", element: "땅", theme: "물질, 건강, 직업" }
    }.freeze

    RANK_NAMES = {
      1 => "에이스", 2 => "2", 3 => "3", 4 => "4", 5 => "5", 6 => "6", 7 => "7",
      8 => "8", 9 => "9", 10 => "10", 11 => "시종", 12 => "기사", 13 => "여왕", 14 => "왕"
    }.freeze

    # 마이너 아르카나 의미 데이터
    MINOR_MEANINGS = {
      wands: {
        1  => { upright: "영감, 새로운 시작, 창조적 잠재력", reversed: "지연, 동기 상실, 망설임" },
        2  => { upright: "미래 계획, 결정의 순간, 발견", reversed: "미결정, 두려움, 무계획" },
        3  => { upright: "확장, 성장, 해외 여행, 기회", reversed: "장애물, 지연, 제한" },
        4  => { upright: "축하, 안정, 가정의 행복, 화합", reversed: "불안, 임시 안정, 갈등" },
        5  => { upright: "경쟁, 갈등, 대립, 도전", reversed: "갈등 회피, 해결, 타협" },
        6  => { upright: "승리, 인정, 자신감, 리더십", reversed: "오만, 실패의 두려움, 지연" },
        7  => { upright: "방어, 끈기, 도전, 입장 고수", reversed: "포기, 압도감, 타협" },
        8  => { upright: "속도, 변화, 빠른 진전, 여행", reversed: "지연, 좌절, 속도 조절" },
        9  => { upright: "인내, 용기, 끈기, 경계심", reversed: "피로, 완고함, 방어적" },
        10 => { upright: "과부하, 책임, 스트레스, 완수", reversed: "짐 내려놓기, 위임, 해소" },
        11 => { upright: "모험, 열정, 자유로운 영혼", reversed: "경솔함, 방향 상실, 지루함" },
        12 => { upright: "에너지, 열정, 모험, 변화", reversed: "성급함, 분노, 좌절" },
        13 => { upright: "자신감, 독립, 결단력, 열정", reversed: "요구과다, 질투, 복수심" },
        14 => { upright: "리더십, 비전, 사업 성공", reversed: "독재, 무자비함, 고압적" }
      },
      cups: {
        1  => { upright: "새로운 사랑, 기쁨, 직감, 감성", reversed: "감정 억압, 공허함, 막힘" },
        2  => { upright: "파트너십, 상호 존중, 사랑의 시작", reversed: "불균형, 이별, 오해" },
        3  => { upright: "우정, 축하, 커뮤니티, 유대감", reversed: "외로움, 과음, 사교 피로" },
        4  => { upright: "내면 성찰, 무관심, 기회 놓침", reversed: "새로운 시각, 동기 부여" },
        5  => { upright: "슬픔, 상실, 후회, 비관", reversed: "회복, 용서, 앞으로 나아감" },
        6  => { upright: "추억, 향수, 순수한 기쁨, 과거의 인연", reversed: "과거 집착, 미성숙" },
        7  => { upright: "환상, 선택 과다, 공상, 유혹", reversed: "현실 인식, 결단, 명확함" },
        8  => { upright: "떠남, 포기, 더 깊은 탐구", reversed: "두려움, 집착, 포기 불가" },
        9  => { upright: "소원 성취, 만족, 행복, 풍요", reversed: "불만족, 탐욕, 물질주의" },
        10 => { upright: "가정의 행복, 조화, 완전한 사랑", reversed: "가정 불화, 불완전, 갈등" },
        11 => { upright: "창의력, 호기심, 직감적 메시지", reversed: "감정적 미성숙, 공상" },
        12 => { upright: "로맨스, 매력, 감성적 접근", reversed: "감정 조종, 변덕, 나르시시즘" },
        13 => { upright: "연민, 돌봄, 감성 지능, 직관력", reversed: "감정적 불안, 의존, 질투" },
        14 => { upright: "감정적 균형, 지혜, 외교적 리더십", reversed: "감정 조종, 냉담, 억압" }
      },
      swords: {
        1  => { upright: "명확함, 진실, 정신적 힘, 돌파구", reversed: "혼란, 잔인함, 오용" },
        2  => { upright: "결정 어려움, 균형, 교착 상태", reversed: "정보 과부하, 우유부단" },
        3  => { upright: "마음의 상처, 슬픔, 이별, 고통", reversed: "회복, 용서, 치유" },
        4  => { upright: "휴식, 회복, 명상, 재충전", reversed: "불안, 번아웃, 강제 휴식" },
        5  => { upright: "갈등, 패배, 긴장, 논쟁", reversed: "화해, 애도, 앞으로 나아감" },
        6  => { upright: "이동, 전환, 변화, 새로운 환경", reversed: "정체, 미해결 문제, 저항" },
        7  => { upright: "속임수, 전략, 은밀한 행동", reversed: "양심, 고백, 전략 실패" },
        8  => { upright: "속박, 제한, 무력감, 자기 검열", reversed: "해방, 자유, 새로운 관점" },
        9  => { upright: "불안, 걱정, 악몽, 스트레스", reversed: "회복, 희망, 걱정 해소" },
        10 => { upright: "배신, 끝, 바닥, 극적 종결", reversed: "회복, 재생, 최악은 지남" },
        11 => { upright: "호기심, 경계, 새로운 아이디어", reversed: "험담, 스파이, 부주의" },
        12 => { upright: "야심, 행동, 충동, 빠른 사고", reversed: "잔인함, 서두름, 무모함" },
        13 => { upright: "독립, 지성, 비판적 사고, 경계", reversed: "잔인함, 편협함, 고립" },
        14 => { upright: "지적 힘, 권위, 진실, 명확한 사고", reversed: "권력 남용, 냉혹, 조종" }
      },
      pentacles: {
        1  => { upright: "새로운 재정 기회, 번영, 풍요의 시작", reversed: "기회 상실, 부족, 무계획" },
        2  => { upright: "균형, 적응, 우선순위 조정", reversed: "혼란, 과부하, 불균형" },
        3  => { upright: "팀워크, 기술 향상, 인정, 학습", reversed: "동기 상실, 품질 저하" },
        4  => { upright: "절약, 안정, 보수적, 자산 보호", reversed: "탐욕, 인색, 물질 집착" },
        5  => { upright: "재정 어려움, 고립, 건강 문제", reversed: "회복, 도움, 영적 풍요" },
        6  => { upright: "관대함, 나눔, 베풂, 재정적 도움", reversed: "부채, 이기심, 조건부 도움" },
        7  => { upright: "인내, 장기 투자, 결실 대기", reversed: "조급함, 잘못된 투자, 좌절" },
        8  => { upright: "장인 정신, 기술 연마, 집중, 헌신", reversed: "완벽주의, 반복, 무의미" },
        9  => { upright: "풍요, 사치, 자립, 재정적 안정", reversed: "과소비, 불안, 허영" },
        10 => { upright: "부, 유산, 가족의 번영, 은퇴", reversed: "재정 손실, 가업 갈등" },
        11 => { upright: "학습, 새로운 기회, 목표 설정", reversed: "기회 놓침, 비현실적 목표" },
        12 => { upright: "노력, 끈기, 책임감, 안정적 진행", reversed: "게으름, 정체, 무관심" },
        13 => { upright: "풍요, 실용성, 양육, 재정 안정", reversed: "과보호, 집착, 불안정" },
        14 => { upright: "성공, 부, 리더십, 안정, 자산", reversed: "탐욕, 물질만능주의, 독점" }
      }
    }.freeze

    # 전체 78장 카드 생성
    def all_cards
      @all_cards ||= begin
        cards = MAJOR_ARCANA.dup
        card_id = 22
        SUIT_INFO.each do |suit_key, suit_data|
          (1..14).each do |rank|
            meanings = MINOR_MEANINGS[suit_key][rank]
            cards << {
              id: card_id,
              name: "#{suit_data[:name]} #{RANK_NAMES[rank]}",
              en: "#{RANK_NAMES[rank]} of #{suit_key.to_s.capitalize}",
              emoji: suit_data[:emoji],
              suit: suit_key.to_s,
              rank: rank,
              upright: meanings[:upright],
              reversed: meanings[:reversed]
            }
            card_id += 1
          end
        end
        cards
      end
    end

    SPREADS = {
      three_card: { name: "과거·현재·미래", count: 3, positions: ["과거", "현재", "미래"] },
      love:       { name: "연애 타로",      count: 3, positions: ["나의 마음", "상대의 마음", "관계의 미래"] },
      career:     { name: "커리어 타로",    count: 3, positions: ["현재 상황", "도전/기회", "결과"] },
      celtic:     { name: "켈틱 크로스",    count: 10, positions: ["현재", "도전", "의식", "무의식", "과거", "미래", "자세", "환경", "희망/두려움", "결과"] },
      year:       { name: "올해의 타로",    count: 5, positions: ["상반기", "도전", "조언", "하반기", "올해의 키워드"] }
    }.freeze

    # 타로 카드 뽑기 (78장 전체에서)
    def draw(birth_date, spread_type = :three_card, topic = "general")
      spread = SPREADS[spread_type] || SPREADS[:three_card]
      count = spread[:count]
      deck = all_cards

      # 시드 생성 (날짜+주제별 결정론적)
      seed = (birth_date.year * 31 + birth_date.month * 37 + birth_date.day * 41 + Date.today.yday + topic.hash.abs) % 100000

      # 카드 뽑기 (중복 없이)
      drawn_ids = []
      drawn = []
      rng = seed

      count.times do
        loop do
          idx = rng % deck.size
          reversed = (rng / deck.size) % 3 == 0  # 33% 확률로 역방향
          unless drawn_ids.include?(idx)
            drawn_ids << idx
            drawn << deck[idx].merge(reversed: reversed)
            break
          end
          rng += 7
        end
        rng = (rng * 1103515245 + 12345) % (2**31)
      end

      reading = drawn.each_with_index.map do |card, i|
        pos = spread[:positions][i] || "카드 #{i + 1}"
        {
          position: pos,
          card: card,
          meaning: card[:reversed] ? card[:reversed] : card[:upright],
          direction: card[:reversed] ? "역방향 🔄" : "정방향 ✨",
          suit_info: card[:suit] == "major" ? nil : SUIT_INFO[card[:suit].to_sym]
        }
      end

      overall = generate_overall(reading, spread_type)

      { spread: spread, cards: reading, overall: overall, spread_type: spread_type, total_deck: deck.size }
    end

    # 레거시 호환: CARDS 상수 유지
    CARDS = MAJOR_ARCANA

    private

    def generate_overall(reading, type)
      positives = reading.count { |r| !r[:card][:reversed] }
      total = reading.size
      ratio = (positives.to_f / total * 100).round

      base = case ratio
      when 80..100 then "매우 긍정적인 에너지가 가득해요! 자신감을 갖고 앞으로 나아가세요! 🌟"
      when 60..79 then "전반적으로 좋은 기운이에요. 조심할 점만 유의하면 좋은 결과가 있을 거예요! 😊"
      when 40..59 then "도전과 변화의 시기예요. 내면의 목소리에 귀 기울이세요. 💭"
      when 20..39 then "신중해야 할 때예요. 서두르지 말고 준비하면 기회가 찾아와요! 🙏"
      else "지금은 멈춰서 돌아볼 때예요. 내면을 정비하면 곧 좋은 기운이 와요! 🌈"
      end

      # 마이너/메이저 분포 분석
      major_count = reading.count { |r| r[:card][:suit] == "major" }
      if major_count >= (total / 2.0).ceil
        base += " 메이저 아르카나가 많아 운명적 전환의 시기입니다."
      end

      # 수트 분석
      suit_counts = reading.reject { |r| r[:card][:suit] == "major" }
                          .group_by { |r| r[:card][:suit] }
                          .transform_values(&:count)
      dominant_suit = suit_counts.max_by { |_, v| v }&.first
      if dominant_suit && SUIT_INFO[dominant_suit.to_sym]
        info = SUIT_INFO[dominant_suit.to_sym]
        base += " #{info[:name]}(#{info[:element]}) 에너지가 강해요: #{info[:theme]}."
      end

      base
    end
  end
end
