# frozen_string_literal: true

module SajuEngine
  module EarthlyBranches
    # 12지지 (十二地支)
    BRANCHES = %w[자 축 인 묘 진 사 오 미 신 유 술 해].freeze
    BRANCHES_HANJA = %w[子 丑 寅 卯 辰 巳 午 未 申 酉 戌 亥].freeze

    # 지지 → 띠 동물
    BRANCH_ANIMALS = {
      '자' => '쥐', '축' => '소', '인' => '호랑이', '묘' => '토끼',
      '진' => '용', '사' => '뱀', '오' => '말', '미' => '양',
      '신' => '원숭이', '유' => '닭', '술' => '개', '해' => '돼지'
    }.freeze

    # 지지 → 띠 이모지
    BRANCH_EMOJIS = {
      '자' => '🐭', '축' => '🐮', '인' => '🐯', '묘' => '🐰',
      '진' => '🐲', '사' => '🐍', '오' => '🐴', '미' => '🐑',
      '신' => '🐵', '유' => '🐔', '술' => '🐶', '해' => '🐷'
    }.freeze

    # 지지 → 오행 매핑
    BRANCH_ELEMENTS = {
      '자' => '수', '축' => '토', '인' => '목', '묘' => '목',
      '진' => '토', '사' => '화', '오' => '화', '미' => '토',
      '신' => '금', '유' => '금', '술' => '토', '해' => '수'
    }.freeze

    # 지지 → 음양
    BRANCH_YINYANG = {
      '자' => '양', '축' => '음', '인' => '양', '묘' => '음',
      '진' => '양', '사' => '음', '오' => '양', '미' => '음',
      '신' => '양', '유' => '음', '술' => '양', '해' => '음'
    }.freeze

    # 지지 → 시간대 매핑 (시주 계산용)
    BRANCH_HOURS = {
      '자' => (23..24).to_a + (0..0).to_a, # 23:00~01:00
      '축' => (1..2).to_a,     # 01:00~03:00
      '인' => (3..4).to_a,     # 03:00~05:00
      '묘' => (5..6).to_a,     # 05:00~07:00
      '진' => (7..8).to_a,     # 07:00~09:00
      '사' => (9..10).to_a,    # 09:00~11:00
      '오' => (11..12).to_a,   # 11:00~13:00
      '미' => (13..14).to_a,   # 13:00~15:00
      '신' => (15..16).to_a,   # 15:00~17:00
      '유' => (17..18).to_a,   # 17:00~19:00
      '술' => (19..20).to_a,   # 19:00~21:00
      '해' => (21..22).to_a    # 21:00~23:00
    }.freeze

    # 시간 → 지지 변환
    def self.branch_for_hour(hour)
      case hour
      when 23, 0 then '자'
      when 1, 2  then '축'
      when 3, 4  then '인'
      when 5, 6  then '묘'
      when 7, 8  then '진'
      when 9, 10 then '사'
      when 11, 12 then '오'
      when 13, 14 then '미'
      when 15, 16 then '신'
      when 17, 18 then '유'
      when 19, 20 then '술'
      when 21, 22 then '해'
      end
    end

    def self.element(branch)
      BRANCH_ELEMENTS[branch]
    end

    def self.animal(branch)
      BRANCH_ANIMALS[branch]
    end

    def self.index(branch)
      BRANCHES.index(branch)
    end

    def self.from_index(idx)
      BRANCHES[idx % 12]
    end
  end
end
