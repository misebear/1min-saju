# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if session[:birth_date].present?
      @birth_date = Date.parse(session[:birth_date])
      @birth_hour = session[:birth_hour].to_i
      @gender = session[:gender] || "남"

      @analysis = SajuEngine.full_analysis(@birth_date, @birth_hour, @gender)
      @daily = @analysis[:daily_fortune]

      # Famous people with similar day pillar
      saju = @analysis[:saju]
      day_stem = saju[:day][:stem]
      day_branch = saju[:day][:branch]
      @famous_people = find_famous_people(day_stem, day_branch)
    end
  end

  private

  def find_famous_people(day_stem, day_branch)
    # Famous people mapped by day pillar (일주)
    famous_db = {
      "갑자" => [
        { name: "이순신", emoji: "⚔️", desc: "조선 명장 · 강인한 리더십" },
        { name: "아이유", emoji: "🎤", desc: "가수 · 감성적이고 다재다능" }
      ],
      "갑인" => [
        { name: "방탄소년단 RM", emoji: "🎵", desc: "리더 · 지적이고 창의적" },
        { name: "정약용", emoji: "📚", desc: "실학자 · 학문과 실천" }
      ],
      "갑진" => [
        { name: "손흥민", emoji: "⚽", desc: "축구선수 · 끈기와 집중력" },
        { name: "세종대왕", emoji: "👑", desc: "조선 4대왕 · 위대한 업적" }
      ],
      "갑오" => [
        { name: "박보검", emoji: "🎬", desc: "배우 · 따뜻하고 성실한 성격" },
        { name: "윤동주", emoji: "✒️", desc: "시인 · 깊은 감성" }
      ],
      "갑신" => [
        { name: "전지현", emoji: "🌟", desc: "배우 · 카리스마와 매력" },
        { name: "김연아", emoji: "⛸️", desc: "피겨여왕 · 완벽주의" }
      ],
      "갑술" => [
        { name: "유재석", emoji: "😄", desc: "MC · 국민MC의 친화력" },
        { name: "이영애", emoji: "🌸", desc: "배우 · 우아함의 대명사" }
      ],
      "을축" => [
        { name: "블랙핑크 제니", emoji: "💎", desc: "아이돌 · 개성과 매력" },
        { name: "이효리", emoji: "🔥", desc: "가수 · 자유로운 영혼" }
      ],
      "을묘" => [
        { name: "임영웅", emoji: "🎶", desc: "가수 · 따뜻한 감성" },
        { name: "백종원", emoji: "👨‍🍳", desc: "요리연구가 · 사업적 감각" }
      ],
      "을사" => [
        { name: "공유", emoji: "🎭", desc: "배우 · 깊이 있는 매력" },
        { name: "강다니엘", emoji: "🕺", desc: "아이돌 · 열정적" }
      ],
      "을미" => [
        { name: "수지", emoji: "💫", desc: "배우/가수 · 국민 첫사랑" },
        { name: "정해인", emoji: "🌊", desc: "배우 · 차분한 매력" }
      ],
      "을유" => [
        { name: "BTS 정국", emoji: "🎤", desc: "아이돌 · 황금막내" },
        { name: "한소희", emoji: "🌹", desc: "배우 · 신비로운 매력" }
      ],
      "을해" => [
        { name: "송혜교", emoji: "🌺", desc: "배우 · 시대를 초월한 미" },
        { name: "이종석", emoji: "📖", desc: "배우 · 지적인 매력" }
      ],
      "병자" => [
        { name: "이병헌", emoji: "🎬", desc: "배우 · 카리스마의 정석" },
        { name: "안성기", emoji: "🏆", desc: "배우 · 국민배우" }
      ],
      "병인" => [
        { name: "김수현", emoji: "⭐", desc: "배우 · 감성 연기의 달인" },
        { name: "박지성", emoji: "⚽", desc: "축구선수 · 끝없는 노력" }
      ],
      "병진" => [
        { name: "BTS 뷔", emoji: "🎨", desc: "아이돌 · 예술적 감성" },
        { name: "장원영", emoji: "✨", desc: "아이돌 · 긍정의 아이콘" }
      ],
      "병오" => [
        { name: "김태리", emoji: "🎭", desc: "배우 · 당찬 매력" },
        { name: "나폴레옹", emoji: "👑", desc: "황제 · 불굴의 의지" }
      ],
      "병신" => [
        { name: "이민호", emoji: "💕", desc: "배우 · 한류스타" },
        { name: "송중기", emoji: "🌟", desc: "배우 · 부드러운 카리스마" }
      ],
      "병술" => [
        { name: "아인슈타인", emoji: "🧠", desc: "물리학자 · 천재적 사고" },
        { name: "강동원", emoji: "🎬", desc: "배우 · 독보적 존재감" }
      ],
      "정축" => [
        { name: "원빈", emoji: "👤", desc: "배우 · 압도적 비주얼" },
        { name: "김고은", emoji: "🌙", desc: "배우 · 맑은 눈빛" }
      ],
      "정묘" => [
        { name: "현빈", emoji: "💝", desc: "배우 · 로맨틱 가이" },
        { name: "조용필", emoji: "🎵", desc: "가왕 · 한국 대중음악의 전설" }
      ],
      "정사" => [
        { name: "조인성", emoji: "🌟", desc: "배우 · 남성미의 정석" },
        { name: "김연경", emoji: "🏐", desc: "배구선수 · 불굴의 투지" }
      ],
      "정미" => [
        { name: "하정우", emoji: "🎭", desc: "배우 · 천의 얼굴" },
        { name: "송강", emoji: "💫", desc: "배우 · 순정만화 비주얼" }
      ],
      "정유" => [
        { name: "이도현", emoji: "🌱", desc: "배우 · 상승세의 아이콘" },
        { name: "김세정", emoji: "🎤", desc: "가수/배우 · 다재다능" }
      ],
      "정해" => [
        { name: "차은우", emoji: "✨", desc: "아이돌/배우 · 조각같은 외모" },
        { name: "윤아", emoji: "🌸", desc: "아이돌/배우 · 국민여동생" }
      ],
      "무자" => [
        { name: "이광수", emoji: "🤣", desc: "배우 · 유머의 달인" },
        { name: "박은빈", emoji: "⭐", desc: "배우 · 연기 천재" }
      ],
      "무인" => [
        { name: "마동석", emoji: "💪", desc: "배우 · 강인함의 아이콘" },
        { name: "빌게이츠", emoji: "💻", desc: "기업가 · 혁신의 아이콘" }
      ],
      "무진" => [
        { name: "이정재", emoji: "🎬", desc: "배우 · 대체불가 카리스마" },
        { name: "김소현", emoji: "🌺", desc: "배우 · 사극의 여신" }
      ],
      "무오" => [
        { name: "박서준", emoji: "😊", desc: "배우 · 훈훈한 매력" },
        { name: "트와이스 나연", emoji: "🫧", desc: "아이돌 · 에너지 넘치는" }
      ],
      "무신" => [
        { name: "정우성", emoji: "🌟", desc: "배우 · 워너비 외모" },
        { name: "아이브 장원영", emoji: "🦋", desc: "아이돌 · 럭키비키" }
      ],
      "무술" => [
        { name: "김영하", emoji: "📝", desc: "작가 · 베스트셀러 작가" },
        { name: "배두나", emoji: "🎭", desc: "배우 · 할리우드 진출" }
      ],
      "기축" => [
        { name: "전도연", emoji: "🏆", desc: "배우 · 칸 여우주연상" },
        { name: "이승기", emoji: "🎤", desc: "가수/배우 · 만능 엔터테이너" }
      ],
      "기묘" => [
        { name: "엔믹스 해원", emoji: "🎵", desc: "아이돌 · 매력보이스" },
        { name: "황정민", emoji: "🎭", desc: "배우 · 변신의 귀재" }
      ],
      "기사" => [
        { name: "뉴진스 민지", emoji: "💎", desc: "아이돌 · 잇걸" },
        { name: "잡스", emoji: "📱", desc: "기업가 · 혁명적 창의성" }
      ],
      "기미" => [
        { name: "박해일", emoji: "🌿", desc: "배우 · 자연스러운 연기" },
        { name: "남주혁", emoji: "🌟", desc: "배우 · 부드러운 매력" }
      ],
      "기유" => [
        { name: "이성경", emoji: "🌼", desc: "배우/모델 · 청순 매력" },
        { name: "정용진", emoji: "🏢", desc: "기업인 · 독특한 감각" }
      ],
      "기해" => [
        { name: "옹성우", emoji: "🎶", desc: "가수/배우 · 감성보이스" },
        { name: "김태희", emoji: "👸", desc: "배우 · 지성미의 대명사" }
      ],
      "경자" => [
        { name: "고윤정", emoji: "✨", desc: "배우 · 청순미와 카리스마" },
        { name: "이천희", emoji: "😄", desc: "배우 · 반전매력" }
      ],
      "경인" => [
        { name: "류승룡", emoji: "🎭", desc: "배우 · 코믹연기의 신" },
        { name: "한효주", emoji: "🌷", desc: "배우 · 밝은 미소" }
      ],
      "경진" => [
        { name: "정호연", emoji: "🌍", desc: "배우/모델 · 글로벌 스타" },
        { name: "이선균", emoji: "🎬", desc: "배우 · 깊은 연기력" }
      ],
      "경오" => [
        { name: "조승우", emoji: "🎭", desc: "배우 · 뮤지컬의 황제" },
        { name: "김혜수", emoji: "👑", desc: "배우 · 여왕의 품격" }
      ],
      "경신" => [
        { name: "김히어라", emoji: "🌟", desc: "배우 · 떠오르는 별" },
        { name: "봉준호", emoji: "🎬", desc: "감독 · 오스카 수상" }
      ],
      "경술" => [
        { name: "마이클조던", emoji: "🏀", desc: "농구선수 · GOAT" },
        { name: "추자현", emoji: "🌺", desc: "배우 · 한중 스타" }
      ],
      "신축" => [
        { name: "안보현", emoji: "💪", desc: "배우 · 남자다운 매력" },
        { name: "이지은", emoji: "🎤", desc: "가수(아이유) · 음악 천재" }
      ],
      "신묘" => [
        { name: "김우빈", emoji: "🌟", desc: "배우/모델 · 독보적 포스" },
        { name: "슈가", emoji: "🎹", desc: "BTS · 천재 프로듀서" }
      ],
      "신사" => [
        { name: "이서진", emoji: "🧳", desc: "배우 · 다방면 활약" },
        { name: "써니", emoji: "🎤", desc: "소녀시대 · 유쾌한 에너지" }
      ],
      "신미" => [
        { name: "소지섭", emoji: "🖤", desc: "배우 · 시크한 매력" },
        { name: "브루노마스", emoji: "🎵", desc: "가수 · 천재 뮤지션" }
      ],
      "신유" => [
        { name: "박신혜", emoji: "🌸", desc: "배우 · 꾸준한 활동" },
        { name: "GD 권지용", emoji: "👑", desc: "가수 · 패션 아이콘" }
      ],
      "신해" => [
        { name: "에일리", emoji: "🎤", desc: "가수 · 파워 보컬" },
        { name: "강하늘", emoji: "⭐", desc: "배우 · 신뢰의 아이콘" }
      ],
      "임자" => [
        { name: "유해진", emoji: "🎭", desc: "배우 · 연기의 달인" },
        { name: "태연", emoji: "🎤", desc: "소녀시대 · 음색요정" }
      ],
      "임인" => [
        { name: "지드래곤", emoji: "👑", desc: "가수 · K팝의 왕" },
        { name: "천우희", emoji: "🌙", desc: "배우 · 독특한 존재감" }
      ],
      "임진" => [
        { name: "서현진", emoji: "🌟", desc: "배우/가수 · 연기파" },
        { name: "지코", emoji: "🎵", desc: "래퍼/프로듀서 · 재능" }
      ],
      "임오" => [
        { name: "이제훈", emoji: "🎬", desc: "배우 · 스타일리시 연기" },
        { name: "박보영", emoji: "🧚", desc: "배우 · 사랑스러운 톱스타" }
      ],
      "임신" => [
        { name: "딘딘", emoji: "😄", desc: "가수/MC · 유쾌한 매력" },
        { name: "신민아", emoji: "🌊", desc: "배우 · 자연의 아름다움" }
      ],
      "임술" => [
        { name: "이준기", emoji: "⚔️", desc: "배우 · 액션과 감성" },
        { name: "한지민", emoji: "🌸", desc: "배우 · 청순의 대명사" }
      ],
      "계축" => [
        { name: "정해인", emoji: "🌊", desc: "배우 · 차분한 매력" },
        { name: "한가인", emoji: "💐", desc: "배우 · 천상의 미모" }
      ],
      "계묘" => [
        { name: "김지원", emoji: "🎭", desc: "배우 · 작품을 고르는 눈" },
        { name: "도경수(디오)", emoji: "🎤", desc: "아이돌/배우 · 진심의 연기" }
      ],
      "계사" => [
        { name: "송강호", emoji: "🏆", desc: "배우 · 한국영화의 전설" },
        { name: "카리나", emoji: "💫", desc: "에스파 · AI 아이돌" }
      ],
      "계미" => [
        { name: "차태현", emoji: "😊", desc: "배우 · 국민 남동생" },
        { name: "이보영", emoji: "🎬", desc: "배우 · 믿보배" }
      ],
      "계유" => [
        { name: "넷플릭스 배수지", emoji: "🌟", desc: "배우 · 한류스타" },
        { name: "정우", emoji: "🎭", desc: "배우 · 숨은 실력파" }
      ],
      "계해" => [
        { name: "이동욱", emoji: "🦊", desc: "배우 · 로맨스의 아이콘" },
        { name: "김소연", emoji: "🔥", desc: "배우 · 펜트하우스 열연" }
      ]
    }

    pillar = "#{day_stem}#{day_branch}"
    famous_db[pillar] || [
      { name: "독특한 사주의 소유자!", emoji: "⭐", desc: "희귀한 일주 · 특별한 운명" },
      { name: "#{pillar}일주 유명인 연구중", emoji: "🔍", desc: "곧 업데이트 예정" }
    ]
  end
end
