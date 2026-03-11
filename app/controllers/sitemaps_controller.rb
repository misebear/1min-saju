class SitemapsController < ApplicationController
  def show
    @pages = [
      { url: root_url, lastmod: Date.today, changefreq: "daily", priority: 1.0 },
      { url: new_saju_url, lastmod: Date.today, changefreq: "weekly", priority: 0.9 },
      { url: saju_history_url, lastmod: Date.today, changefreq: "daily", priority: 0.8 },
      { url: chat_url, lastmod: Date.today, changefreq: "daily", priority: 0.9 },
      { url: daily_fortune_url, lastmod: Date.today, changefreq: "daily", priority: 0.9 },
      { url: yearly_fortune_url, lastmod: Date.today, changefreq: "weekly", priority: 0.8 },
      { url: tomorrow_fortune_url, lastmod: Date.today, changefreq: "daily", priority: 0.8 },
      { url: specific_fortune_form_url, lastmod: Date.today, changefreq: "weekly", priority: 0.7 },
      { url: new_compatibility_url, lastmod: Date.today, changefreq: "weekly", priority: 0.9 },
      { url: new_blind_compat_url, lastmod: Date.today, changefreq: "weekly", priority: 0.9 },
      { url: new_solo_destiny_url, lastmod: Date.today, changefreq: "weekly", priority: 0.8 },
      { url: new_dream_url, lastmod: Date.today, changefreq: "weekly", priority: 0.8 },
      { url: zodiac_url, lastmod: Date.today, changefreq: "daily", priority: 0.8 },
      { url: tti_fortune_url, lastmod: Date.today, changefreq: "daily", priority: 0.8 },
      { url: new_tarot_url, lastmod: Date.today, changefreq: "weekly", priority: 0.8 },
      { url: new_auspicious_date_url, lastmod: Date.today, changefreq: "weekly", priority: 0.8 },
      { url: new_tojeong_url, lastmod: Date.today, changefreq: "weekly", priority: 0.8 },
      { url: new_psychology_url, lastmod: Date.today, changefreq: "weekly", priority: 0.7 },
      { url: new_past_life_url, lastmod: Date.today, changefreq: "weekly", priority: 0.7 },
      { url: birthstone_url, lastmod: Date.today, changefreq: "monthly", priority: 0.6 },
      { url: new_career_url, lastmod: Date.today, changefreq: "weekly", priority: 0.7 }
    ]

    # 롱테일 SEO 키워드 페이지 동적 추가

    # 1. 띠별 운세 상세 URL (12개 띠)
    animals = %w[쥐 소 호랑이 토끼 용 뱀 말 양 원숭이 닭 개 돼지]
    animals.each do |animal|
      @pages << { url: tti_fortune_url(animal: animal), lastmod: Date.today, changefreq: "daily", priority: 0.8 }
    end

    # 2. 별자리 운세 상세 URL (12개 별자리)
    signs = %w[양 황소 쌍둥이 게 사자 처녀 천칭 전갈 사수 염소 물병 물고기]
    signs.each do |sign|
      @pages << { url: zodiac_url(sign: sign), lastmod: Date.today, changefreq: "daily", priority: 0.8 }
    end

    # 3. 꿈해몽 상세 URL (DB에 저장된 해몽 키워드를 활용해 개별 페이지 색인)
    # 서버 메모리를 고려해 최근 또는 많이 사용된 상위 3000개 키워드만 뽑음
    begin
      dream_keys = DreamInterpretation.order(use_count: :desc).limit(3000).pluck(:keywords_key)
      dream_keys.each do |key|
        # keywords_key 보통 "뱀,물림" 형태이므로 첫번째 명사 위주로 url 추출
        # 여기서는 단순히 q= 파라미터를 붙여 동적 렌더링을 허용
        main_keyword = key.split(",").first
        if main_keyword.present?
          @pages << { url: dream_result_url(q: main_keyword), lastmod: Date.today, changefreq: "monthly", priority: 0.6 }
        end
      end
    rescue => e
      Rails.logger.error "사이트맵에 꿈해몽 노출 실패: #{e.message}"
    end

    respond_to do |format|
      format.xml
    end
  end
end
