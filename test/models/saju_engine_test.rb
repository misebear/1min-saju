# frozen_string_literal: true

require "test_helper"

# 사주 엔진 핵심 로직 단위 테스트
class SajuEngineTest < ActiveSupport::TestCase
  # === 천간 (HeavenlyStems) ===
  test "천간 10개 존재 확인" do
    assert_equal 10, SajuEngine::HeavenlyStems::STEMS.size
    assert_equal %w[갑 을 병 정 무 기 경 신 임 계], SajuEngine::HeavenlyStems::STEMS
  end

  test "천간 오행 매핑 정확성" do
    assert_equal "목", SajuEngine::HeavenlyStems.element("갑")
    assert_equal "목", SajuEngine::HeavenlyStems.element("을")
    assert_equal "화", SajuEngine::HeavenlyStems.element("병")
    assert_equal "금", SajuEngine::HeavenlyStems.element("경")
    assert_equal "수", SajuEngine::HeavenlyStems.element("임")
  end

  test "천간 음양 매핑 정확성" do
    assert_equal "양", SajuEngine::HeavenlyStems.yinyang("갑")
    assert_equal "음", SajuEngine::HeavenlyStems.yinyang("을")
  end

  # === 지지 (EarthlyBranches) ===
  test "지지 12개 존재 확인" do
    assert_equal 12, SajuEngine::EarthlyBranches::BRANCHES.size
    assert_equal %w[자 축 인 묘 진 사 오 미 신 유 술 해], SajuEngine::EarthlyBranches::BRANCHES
  end

  test "지지 동물 매핑" do
    assert_equal "쥐", SajuEngine::EarthlyBranches.animal("자")
    assert_equal "소", SajuEngine::EarthlyBranches.animal("축")
    assert_equal "용", SajuEngine::EarthlyBranches.animal("진")
  end

  test "시간별 지지 결정" do
    assert_equal "자", SajuEngine::EarthlyBranches.branch_for_hour(0)  # 자시 0~1시
    assert_equal "자", SajuEngine::EarthlyBranches.branch_for_hour(1)
    assert_equal "인", SajuEngine::EarthlyBranches.branch_for_hour(3)  # 인시 3~5시
    assert_equal "오", SajuEngine::EarthlyBranches.branch_for_hour(12) # 오시 11~13시
  end

  # === 일주 계산 (PillarCalculator) ===
  test "일주 계산 기준일 검증 (1900-01-01 = 경자)" do
    pillar = SajuEngine::PillarCalculator.calculate_day_pillar(Date.new(1900, 1, 1))
    assert_equal "경", pillar[:stem]
    assert_equal "자", pillar[:branch]
  end

  test "일주 계산 다른 날짜 검증" do
    # 60일 후면 다시 경자
    pillar = SajuEngine::PillarCalculator.calculate_day_pillar(Date.new(1900, 3, 2))
    assert_equal "경", pillar[:stem]
    assert_equal "자", pillar[:branch]
  end

  test "년주 계산 (2026년 = 병오)" do
    pillar = SajuEngine::PillarCalculator.calculate_year_pillar(Date.new(2026, 6, 15))
    assert_equal "병", pillar[:stem]
    assert_equal "오", pillar[:branch]
  end

  test "입춘 전후 년주 경계 테스트" do
    # 2026년 입춘 전 → 2025년(을사)으로 계산되어야 함
    # 입춘은 대략 2월 4일
    before_ipchun = SajuEngine::PillarCalculator.calculate_year_pillar(Date.new(2026, 2, 1))
    assert_equal "을", before_ipchun[:stem]
    assert_equal "사", before_ipchun[:branch]

    # 2026년 입춘 후 → 2026년(병오)
    after_ipchun = SajuEngine::PillarCalculator.calculate_year_pillar(Date.new(2026, 2, 10))
    assert_equal "병", after_ipchun[:stem]
    assert_equal "오", after_ipchun[:branch]
  end

  # === 전체 사주 분석 ===
  test "full_analysis 정상 동작" do
    result = SajuEngine.full_analysis(Date.new(1990, 5, 15), 12, "남")

    assert result.is_a?(Hash)
    assert result[:saju].present?
    assert result[:daily_fortune].present?
    assert result[:yearly_fortune].present?
    assert result[:personality].present?
    assert result[:career].present?
    assert result[:love].present?

    # 사주 기본 구조 확인
    saju = result[:saju]
    assert saju[:year].present?
    assert saju[:month].present?
    assert saju[:day].present?
    assert saju[:hour].present?
    assert saju[:zodiac].present?
    assert saju[:zodiac_emoji].present?
  end

  test "full_analysis 여성 분석" do
    result = SajuEngine.full_analysis(Date.new(1995, 12, 25), 6, "여")
    assert result.is_a?(Hash)
    assert_equal "여", result[:saju][:gender]
  end

  # === 오행 분석 ===
  test "오행 분포 계산" do
    # 테스트용 임시 주 구조
    pillars = [
      { stem: "갑", branch: "자" },
      { stem: "을", branch: "축" },
      { stem: "병", branch: "인" },
      { stem: "정", branch: "묘" }
    ]
    distribution = SajuEngine::FiveElements.analyze_distribution(pillars)

    assert distribution.is_a?(Hash)
    assert distribution[:목].present? || distribution[:목] == 0
    assert distribution[:화].present? || distribution[:화] == 0
    assert distribution[:토].present? || distribution[:토] == 0
    assert distribution[:금].present? || distribution[:금] == 0
    assert distribution[:수].present? || distribution[:수] == 0
  end

  # === 궁합 분석 ===
  test "궁합 분석 정상 동작" do
    p1 = SajuEngine.full_analysis(Date.new(1990, 3, 15), 10, "남")
    p2 = SajuEngine.full_analysis(Date.new(1992, 7, 20), 14, "여")

    result = SajuEngine.compatibility(p1, p2)
    assert result.is_a?(Hash)
    assert result[:score].present?
    assert result[:score].between?(0, 100)
    assert result[:grade].present?
  end

  # === 꿈해몽 ===
  test "꿈 키워드 추출" do
    keywords = SajuEngine::DreamEngine.find_keywords_public("돼지가 하늘을 나는 꿈을 꿨어요")
    assert keywords.is_a?(Array)
  end

  test "꿈해몽 결과 구조" do
    result = SajuEngine::DreamEngine.interpret("큰 뱀이 집에 들어오는 꿈")
    assert result.is_a?(Hash)
  end

  # === 타로 ===
  test "타로 카드 데이터 존재" do
    assert SajuEngine::TarotEngine.respond_to?(:draw_cards) || SajuEngine::TarotEngine.respond_to?(:interpret)
  end

  # === 심리풀이 ===
  test "심리풀이 질문 목록 존재" do
    questions = SajuEngine::PsychologyEngine.questions
    assert questions.is_a?(Array)
    assert questions.size >= 4
  end

  test "심리풀이 분석" do
    answers = [ "산", "파란색", "고양이", "바다" ]
    result = SajuEngine::PsychologyEngine.analyze(answers)
    assert result.is_a?(Hash)
  end

  # === 전생운 ===
  test "전생운 분석 정상 동작" do
    result = SajuEngine::PastLifeEngine.analyze(Date.new(1995, 8, 10), 14, "여")
    assert result.is_a?(Hash)
  end

  # === 취업운 ===
  test "취업운 분석 정상 동작" do
    result = SajuEngine::CareerEngine.analyze(Date.new(2000, 1, 1), 8, "남")
    assert result.is_a?(Hash)
  end

  # === 토정비결 ===
  test "토정비결 분석 정상 동작" do
    result = SajuEngine::TojeongEngine.analyze(Date.new(1988, 6, 15), 10, "남")
    assert result.is_a?(Hash)
  end

  # === 나는솔로 인연풀이 ===
  test "솔로 인연 분석" do
    analysis = SajuEngine.full_analysis(Date.new(1993, 4, 20), 10, "남")
    archetype = SajuEngine::SoloDestiny.analyze_archetype(analysis[:saju])
    assert archetype.present?
  end
end
