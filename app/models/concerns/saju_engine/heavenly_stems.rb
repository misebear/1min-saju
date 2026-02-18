# frozen_string_literal: true

module SajuEngine
  module HeavenlyStems
    # 10천간 (十天干)
    STEMS = %w[갑 을 병 정 무 기 경 신 임 계].freeze
    STEMS_HANJA = %w[甲 乙 丙 丁 戊 己 庚 辛 壬 癸].freeze

    # 천간 → 오행 매핑
    STEM_ELEMENTS = {
      '갑' => '목', '을' => '목',
      '병' => '화', '정' => '화',
      '무' => '토', '기' => '토',
      '경' => '금', '신' => '금',
      '임' => '수', '계' => '수'
    }.freeze

    # 천간 → 음양
    STEM_YINYANG = {
      '갑' => '양', '을' => '음',
      '병' => '양', '정' => '음',
      '무' => '양', '기' => '음',
      '경' => '양', '신' => '음',
      '임' => '양', '계' => '음'
    }.freeze

    # 천간 → 색상 (UI용)
    STEM_COLORS = {
      '갑' => '#4CAF50', '을' => '#81C784',
      '병' => '#F44336', '정' => '#EF5350',
      '무' => '#FFC107', '기' => '#FFD54F',
      '경' => '#ECEFF1', '신' => '#CFD8DC',
      '임' => '#2196F3', '계' => '#64B5F6'
    }.freeze

    # 천간 → 이모지
    STEM_EMOJIS = {
      '갑' => '🌳', '을' => '🌿',
      '병' => '🔥', '정' => '🕯️',
      '무' => '⛰️', '기' => '🏜️',
      '경' => '⚔️', '신' => '💎',
      '임' => '🌊', '계' => '💧'
    }.freeze

    def self.element(stem)
      STEM_ELEMENTS[stem]
    end

    def self.yinyang(stem)
      STEM_YINYANG[stem]
    end

    def self.index(stem)
      STEMS.index(stem)
    end

    def self.from_index(idx)
      STEMS[idx % 10]
    end
  end
end
