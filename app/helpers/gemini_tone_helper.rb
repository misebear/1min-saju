# frozen_string_literal: true

require "ostruct"

module GeminiToneHelper
  FORTUNE_STYLE_LABELS = {
    "갓생모드" => "차분한 리듬",
    "멘탈수호" => "마음 챙김",
    "포커페이스" => "담백한 태도",
    "주인공버프" => "자신감 상승",
    "주인공재질" => "돋보이는 존재감",
    "분위기여신" => "부드러운 존재감",
    "올라운더" => "균형 잡힌 무드",
    "아이디어뱅크" => "아이디어 감도",
    "평온모드" => "잔잔한 리듬",
    "커리어우먼" => "일에 집중하는 무드",
    "감성천재" => "감각이 살아나는 무드",
    "냉미남/냉미녀" => "차분한 매력",
    "커리어하이" => "일이 잘 풀리는 흐름",
    "기세천재" => "기세가 살아나는 무드",
    "갓생주인공" => "활력이 도는 무드",
    "주인공카리스마" => "자신감 있는 무드",
    "갓생장인" => "단정한 리듬"
  }.freeze

  COMPATIBILITY_TYPE_LABELS = {
    "갓생 시너지 커플" => "균형이 좋은 커플",
    "자석 케미" => "자석처럼 끌리는 커플",
    "밀당 천재 커플" => "리듬이 살아 있는 커플",
    "단짠단짠 케미" => "상반된 매력이 잘 맞는 케미",
    "소울메이트 각" => "잘 통하는 소울메이트형",
    "성장형 커플" => "함께 자라는 커플",
    "단짠 성장형 커플" => "온도 차가 매력인 성장형 커플",
    "갓생 시너지" => "균형이 좋은 케미",
    "자석 밀당 케미" => "당김과 여유가 공존하는 케미",
    "갓생 메이트" => "일상 호흡이 잘 맞는 메이트",
    "운명적 갓벽 커플" => "운명처럼 잘 맞는 커플",
    "불꽃 시너지" => "강하게 끌리는 시너지",
    "자석형 커플" => "자연스럽게 끌리는 커플",
    "단짠 밸런스 케미" => "상반된 매력이 조화로운 케미",
    "파워 성장형 커플" => "서로를 끌어올리는 성장형 커플",
    "데칼코마니 커플" => "닮은 결의 커플",
    "자석 밀착 케미" => "가까워질수록 편안한 케미",
    "든든한 나무 케미" => "서로를 지지하는 케미"
  }.freeze

  PHRASE_REPLACEMENTS = [
    [/플러팅 폼 장난 아님/, "호감 표현이 자연스럽게 살아나는 날이야"],
    [/도파민 폭발각이야/, "설렘이 커지는 흐름이야"],
    [/맑은 눈의 광인/, "과하게 들뜬 상태"],
    [/['‘’]?심쿵['‘’]?할 수 있는/, "마음이 움직일 수 있는"],
    [/심쿵할 수 있는/, "마음이 움직일 수 있는"],
    [/럭키비키 그 자체지/, "기분 좋게 풀리는 흐름이야"],
    [/럭키비키한 하루야/, "기분 좋게 풀리는 하루야"],
    [/럭키비키잖아/, "기분 좋게 풀리는 흐름이야"],
    [/주인공인 행운이 스며든 하루야/, "내 리듬을 믿고 움직이면 잘 풀리는 하루야"],
    [/레드카펫 깔아주는 바이브/, "길을 부드럽게 열어주는 분위기"],
    [/갓생 가보자고/, "좋은 흐름을 이어가 보자"],
    [/금융치료/, "기분 전환"],
    [/오히려 좋아/, "그것도 괜찮아"],
    [/장비빨/, "준비"],
    [/하이퍼 모드/, "기운이 바짝 도는 흐름"],
    [/멘탈 디톡스/, "마음 정리"],
    [/유니버스가 보내는/, "흐름이 전하는"],
    [/유니버스/, "흐름"],
    [/시그널/, "신호"],
    [/모먼트/, "순간"],
    [/힙플/, "분위기 좋은 곳"],
    [/럭키 데이/, "기분 좋은 날"],
    [/대박 시그널/, "좋은 신호"],
    [/무지성 데이트/, "가볍게 즐기는 데이트"],
    [/심박수 폭발/, "마음이 크게 움직이는 흐름"],
    [/가보자고!?/, "흐름을 타 보자."],
    [/고고!?/, "움직여 보자."],
    [/고\(Go\)해봐!?/, "한 걸음 나서봐."],
    [/go!/, "움직여 보자."],
    [/Go!/, "움직여 보자."],
    [/텐션 세계관/, "분위기"],
    [/시너지 미쳤다/, "시너지가 돋보여"],
    [/시너지가 미쳤어요/, "시너지가 돋보여요"],
    [/오늘 내 추진력 폼 미쳤으니까/, "오늘 내 추진력이 잘 살아나니까"],
    [/소울메이트 각/, "서로 잘 통하는 관계"],
    [/움직여 보자\.하면서도/, "경쾌하면서도"],
    [/가득 차오른되는/, "가득 차오르는"]
  ].freeze

  POST_REPLACEMENTS = [
    [/에너지 기세가 좋다/, "에너지가 살아난다"],
    [/멘탈 컨디션 기세가 좋다/, "마음 컨디션이 좋다"],
    [/기세가 좋은 생산성/, "생산성이 잘 살아나는 흐름"],
    [/기세가 좋은 성장이 가능해/, "차분하게 성장할 수 있어"],
    [/행운이 스며든 성취감/, "기분 좋은 성취감"],
    [/행운이 스며든 신호/, "좋은 신호"],
    [/기분 좋은 흐름니까/, "좋은 흐름이니까"],
    [/가득 차오른됐/, "가득 찼"],
    [/잘 맞는하게/, "자연스럽게"],
    [/순간가/, "순간이"],
    [/흐름가/, "흐름이"],
    [/남겨되는/, "남겨지는"],
    [/신호을/, "신호를"],
    [/좋은 흐름로/, "좋은 흐름으로"],
    [/좋은 흐름 모드로/, "좋은 흐름으로"],
    [/좋은 흐름 가능!/, "차분하게 잘 풀릴 수 있어."],
    [/좋은 흐름 가능/, "차분하게 잘 풀릴 수 있어"],
    [/좋은 흐름을 이어가기 좋아!/, "좋은 흐름을 이어가기 좋은 때야."],
    [/좋은 흐름을 이어가기 좋아/, "좋은 흐름을 이어가기 좋은 때야"],
    [/좋은 흐름 순간/, "좋은 흐름"],
    [/평온한 좋은 흐름 가능!/, "평온하게 잘 풀릴 수 있어."],
    [/평온한 좋은 흐름 가능/, "평온하게 잘 풀릴 수 있어"],
    [/쓰는 돈이 그것도 괜찮아/, "쓰는 돈도 괜찮아"],
    [/온도가 참 인상적이야\.\?/, "온도가 참 인상적이야."],
    [/훨씬 훨씬/, "훨씬"],
    [/온도 정말이야\?/, "온도가 참 인상적이야."],
    [/승률 높음!/, "반응이 좋을 가능성이 높아!"],
    [/승률 높음/, "반응이 좋을 가능성이 높아"],
    [/이득인 부분, 인정\?/, "훨씬 나은 선택이 될 수 있어."],
    [/정말이야\.\?/, "정말이야?"],
    [/내가 세상의 주인공인 기분 좋게 풀리는 하루야/, "내 리듬을 믿고 움직이면 잘 풀리는 하루야"],
    [/오늘 내 추진력 기세가 좋다/, "오늘 내 추진력이 살아난다"],
    [/움직여 보자\.하면서도/, "경쾌하면서도"],
    [/분위기을/, "분위기를"],
    [/분위기이/, "분위기가"],
    [/가득 차오른되는/, "가득 차오르는"],
    [/가득 차오른!/, "가득 찬!"],
    [/새로운 기운 리셋/, "새로운 흐름 정리"],
    [/기운 리셋/, "흐름 정리"],
    [/좋은 흐름 모드/, "좋은 흐름"],
    [/좋은 흐름 살기 성공/, "좋은 흐름을 이어가기 좋아"],
    [/좋은 흐름 살기/, "좋은 흐름을 이어가기"],
    [/리부트/, "다시 세우기"]
  ].freeze

  SHARED_REPLACEMENTS = [
    [/갓벽하게/, "자연스럽게"],
    [/추구미를/, "취향을"],
    [/추구미가/, "취향이"],
    [/추구미는/, "취향은"],
    [/추구미와/, "취향과"],
    [/추구미로/, "취향으로"],
    [/럭키비키한/, "행운이 스며든"],
    [/럭키비키/, "기분 좋은 흐름"],
    [/폼 미친/, "기세가 좋은"],
    [/폼 미쳤다/, "기세가 좋다"],
    [/폼 장난 아님/, "분위기가 꽤 좋다"],
    [/도파민/, "설렘"],
    [/시성비/, "만족도"],
    [/추구미/, "취향"],
    [/갓벽한/, "잘 어울리는"],
    [/갓벽/, "잘 맞는"],
    [/갓생/, "좋은 흐름"],
    [/억까 없는/, "괜한 방해 없는"],
    [/억까/, "예상 밖 변수"],
    [/플러팅/, "호감 표현"],
    [/자만추/, "자연스러운 만남"],
    [/찐사랑/, "깊은 애정"],
    [/힙한/, "세련된"],
    [/힙하네요/, "세련되게 느껴지네요"],
    [/힙해요/, "세련되게 느껴져요"],
    [/힙하다/, "세련되다"],
    [/무지성/, "즉흥적으로"],
    [/광인/, "과열된 상태"],
    [/실화\\?/, "정말이야?"],
    [/풀충전/, "가득 차오른"],
    [/하드캐리/, "든든하게 이끄는 힘"],
    [/뿜뿜/, "가득"],
    [/박제/, "또렷하게 남겨"],
    [/떡상/, "상승"],
    [/심쿵/, "설레는 순간"],
    [/꽁냥/, "다정하게"],
    [/롱런/, "오래 가는"],
    [/대박/, "좋은"],
    [/낭낭/, "가득"]
  ].freeze

  PROFILE_REPLACEMENTS = {
    saju: [
      [/바이브가/, "결이"],
      [/바이브는/, "결은"],
      [/바이브를/, "결을"],
      [/바이브와/, "결과"],
      [/바이브랄까/, "결이랄까"],
      [/바이브/, "결"],
      [/텐션이/, "결이"],
      [/텐션은/, "결은"],
      [/텐션을/, "결을"],
      [/텐션도/, "결도"],
      [/텐션/, "결"],
      [/세계관을/, "분위기를"],
      [/세계관이/, "분위기가"],
      [/세계관은/, "분위기는"],
      [/세계관도/, "분위기도"],
      [/세계관/, "분위기"]
    ],
    daily: [
      [/바이브가/, "분위기가"],
      [/바이브는/, "분위기는"],
      [/바이브를/, "분위기를"],
      [/바이브와/, "분위기와"],
      [/바이브랄까/, "분위기랄까"],
      [/바이브/, "분위기"],
      [/텐션이/, "기세가"],
      [/텐션은/, "기세는"],
      [/텐션을/, "기세를"],
      [/텐션도/, "기세도"],
      [/텐션/, "기세"],
      [/세계관을/, "분위기를"],
      [/세계관이/, "분위기가"],
      [/세계관은/, "분위기는"],
      [/세계관도/, "분위기도"],
      [/세계관/, "분위기"]
    ],
    compatibility: [
      [/바이브가/, "호흡이"],
      [/바이브는/, "호흡은"],
      [/바이브를/, "호흡을"],
      [/바이브와/, "호흡과"],
      [/바이브/, "호흡"],
      [/텐션이/, "온도가"],
      [/텐션은/, "온도는"],
      [/텐션을/, "온도를"],
      [/텐션도/, "온도도"],
      [/텐션/, "온도"],
      [/세계관을/, "결을"],
      [/세계관이/, "결이"],
      [/세계관은/, "결은"],
      [/세계관도/, "결도"],
      [/세계관/, "결"]
    ],
    tarot: [
      [/바이브가/, "기운이"],
      [/바이브는/, "기운은"],
      [/바이브를/, "기운을"],
      [/바이브와/, "기운과"],
      [/바이브/, "기운"],
      [/텐션이/, "집중력이"],
      [/텐션은/, "집중력은"],
      [/텐션을/, "집중력을"],
      [/텐션도/, "집중력도"],
      [/텐션/, "집중력"],
      [/세계관을/, "흐름을"],
      [/세계관이/, "흐름이"],
      [/세계관은/, "흐름은"],
      [/세계관도/, "흐름도"],
      [/세계관/, "흐름"]
    ],
    tti: [
      [/바이브가/, "무드가"],
      [/바이브는/, "무드는"],
      [/바이브를/, "무드를"],
      [/바이브와/, "무드와"],
      [/바이브/, "무드"],
      [/텐션이/, "기세가"],
      [/텐션은/, "기세는"],
      [/텐션을/, "기세를"],
      [/텐션도/, "기세도"],
      [/텐션/, "기세"],
      [/세계관을/, "분위기를"],
      [/세계관이/, "분위기가"],
      [/세계관은/, "분위기는"],
      [/세계관도/, "분위기도"],
      [/세계관/, "분위기"]
    ],
    zodiac: [
      [/바이브가/, "무드가"],
      [/바이브는/, "무드는"],
      [/바이브를/, "무드를"],
      [/바이브와/, "무드와"],
      [/바이브/, "무드"],
      [/텐션이/, "흐름이"],
      [/텐션은/, "흐름은"],
      [/텐션을/, "흐름을"],
      [/텐션도/, "흐름도"],
      [/텐션/, "흐름"],
      [/세계관을/, "분위기를"],
      [/세계관이/, "분위기가"],
      [/세계관은/, "분위기는"],
      [/세계관도/, "분위기도"],
      [/세계관/, "분위기"]
    ]
  }.freeze

  def polished_gemini_fortune(record, surface: :daily)
    return if record.blank?

    OpenStruct.new(
      vibe: polish_gemini_text(record.vibe, profile: surface, mode: :headline),
      money: polish_gemini_text(record.money, profile: surface),
      relationship: polish_gemini_text(record.relationship, profile: surface),
      style: polish_gemini_label(record.style, profile: surface, field: :style),
      lucky_item: polish_gemini_label(record.lucky_item, profile: surface, field: :lucky_item)
    )
  end

  def polished_gemini_compatibility(record)
    return if record.blank?

    OpenStruct.new(
      analysis: polish_gemini_text(record.analysis, profile: :compatibility),
      chemistry_type: polish_gemini_label(record.chemistry_type, profile: :compatibility, field: :chemistry_type),
      dating_style: polish_gemini_text(record.dating_style, profile: :compatibility),
      caution_point: polish_gemini_text(record.caution_point, profile: :compatibility),
      lucky_date: polish_gemini_label(record.lucky_date, profile: :compatibility, field: :lucky_date)
    )
  end

  def polished_gemini_tarot(record)
    return if record.blank?

    OpenStruct.new(
      keyword: polish_gemini_label(record.keyword, profile: :tarot, field: :keyword),
      reading_text: polish_gemini_text(record.reading_text, profile: :tarot),
      advice: polish_gemini_text(record.advice, profile: :tarot),
      lucky_energy: polish_gemini_label(record.lucky_energy, profile: :tarot, field: :lucky_energy)
    )
  end

  def polished_gemini_tti_headline(text)
    polish_gemini_label(text, profile: :tti, field: :headline)
  end

  def polished_gemini_tti_text(text)
    polish_gemini_text(text, profile: :tti)
  end

  def polished_gemini_tti_lucky_point(text)
    polish_gemini_label(text, profile: :tti, field: :lucky_point)
  end

  def polished_gemini_zodiac(record)
    return if record.blank?

    OpenStruct.new(
      headline: polish_gemini_label(record.headline, profile: :zodiac, field: :headline),
      fortune_text: polish_gemini_text(record.fortune_text, profile: :zodiac),
      lucky_point: polish_gemini_label(record.lucky_point, profile: :zodiac, field: :lucky_point)
    )
  end

  def polish_gemini_label(text, profile:, field:)
    return text if text.blank?

    exact = exact_label_replacement(profile, field, text)
    return exact if exact.present?

    polished = polish_gemini_text(text, profile: profile, mode: :label)
    polished.gsub!(/모드\z/, " 무드")
    polished.gsub!(/버프\z/, " 상승")
    polished.gsub!(/재질\z/, " 존재감")
    polished.strip
  end

  def polish_gemini_text(text, profile:, mode: :body)
    return text if text.blank?

    polished = text.to_s.dup

    PHRASE_REPLACEMENTS.each { |pattern, replacement| polished.gsub!(pattern, replacement) }
    PROFILE_REPLACEMENTS.fetch(profile, []).each { |pattern, replacement| polished.gsub!(pattern, replacement) }
    SHARED_REPLACEMENTS.each { |pattern, replacement| polished.gsub!(pattern, replacement) }
    POST_REPLACEMENTS.each { |pattern, replacement| polished.gsub!(pattern, replacement) }

    normalize_gemini_text(polished, mode: mode)
  end

  def exact_label_replacement(profile, field, text)
    case [profile, field]
    when [ :saju, :style ], [ :daily, :style ]
      FORTUNE_STYLE_LABELS[text]
    when [ :compatibility, :chemistry_type ]
      COMPATIBILITY_TYPE_LABELS[text]
    end
  end

  def normalize_gemini_text(text, mode:)
    polished = text.to_s.dup
    polished.gsub!(/[!！]{2,}/, "!")
    polished.gsub!(/[?？]{2,}/, "?")
    polished.gsub!(/\.{2,}/, ".")
    polished.gsub!(/([가-힣])\.\?/, '\1?')
    polished.gsub!(/훨씬\s+훨씬/, "훨씬")
    polished.gsub!(/좋은 흐름 모드 가능!/, "평온하게 잘 풀릴 수 있어.")
    polished.gsub!(/좋은 흐름 모드 가능/, "평온하게 잘 풀릴 수 있어")
    polished.gsub!(/좋은 흐름을 이어가기 좋아!/, "좋은 흐름을 이어가기 좋은 때야.")
    polished.gsub!(/좋은 흐름을 이어가기 좋아/, "좋은 흐름을 이어가기 좋은 때야")
    polished.gsub!(/\s+/, " ")
    polished.gsub!(/\s([,.!?])/, '\1')
    polished.strip!

    polished.gsub!(/\A뉴 /, "새로운 ")

    polished.gsub!(/[.!?]\z/, "") if mode == :label

    polished
  end
end
