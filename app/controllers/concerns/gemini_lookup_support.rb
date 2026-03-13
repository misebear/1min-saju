# frozen_string_literal: true

module GeminiLookupSupport
  private

  def today_iljin(date = Date.today)
    pillar_to_iljin_for_date(date)
  end

  def ilju_for_birth_date(date)
    pillar_to_iljin_for_date(date)
  end

  def lookup_gemini_fortune_for_birth_date(birth_date, date = Date.today)
    GeminiFortune.lookup(today_iljin(date), ilju_for_birth_date(birth_date))
  rescue => e
    Rails.logger.warn("Gemini 운세 조회 실패: #{e.message}")
    nil
  end

  def lookup_gemini_compatibility_for_dates(date_a, date_b)
    GeminiCompatibility.lookup(ilju_for_birth_date(date_a), ilju_for_birth_date(date_b))
  rescue => e
    Rails.logger.warn("Gemini 궁합 조회 실패: #{e.message}")
    nil
  end

  def lookup_gemini_tti_fortune(animal_name, date = Date.today)
    GeminiTtiFortune.lookup(animal_name, today_iljin(date))
  rescue => e
    Rails.logger.warn("Gemini 띠운세 조회 실패: #{e.message}")
    nil
  end

  def lookup_gemini_zodiac_fortune(sign_name, date = Date.today)
    GeminiZodiacFortune.lookup(sign_name, today_iljin(date))
  rescue => e
    Rails.logger.warn("Gemini 별자리 조회 실패: #{e.message}")
    nil
  end

  def lookup_gemini_tarot_reading(card_name, reversed)
    GeminiTarotReading.lookup(card_name, reversed ? "역위치" : "정위치")
  rescue => e
    Rails.logger.warn("Gemini 타로 조회 실패: #{e.message}")
    nil
  end

  def pillar_to_iljin_for_date(date)
    pillar = SajuEngine::PillarCalculator.calculate_day_pillar(date)
    stem_idx = SajuEngine::HeavenlyStems::STEMS.index(pillar[:stem])
    branch_idx = SajuEngine::EarthlyBranches::BRANCHES.index(pillar[:branch])
    hanja_stem = SajuEngine::HeavenlyStems::STEMS_HANJA[stem_idx]
    hanja_branch = SajuEngine::EarthlyBranches::BRANCHES_HANJA[branch_idx]
    "#{hanja_stem}#{hanja_branch}(#{pillar[:stem]}#{pillar[:branch]})"
  end
end
