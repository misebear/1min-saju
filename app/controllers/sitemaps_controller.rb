class SitemapsController < ApplicationController
  def show
    @pages = [
      { url: root_url, lastmod: Date.today, changefreq: "daily", priority: 1.0 },
      { url: about_url, lastmod: Date.today, changefreq: "yearly", priority: 0.4 },
      { url: contact_url, lastmod: Date.today, changefreq: "yearly", priority: 0.4 },
      { url: terms_url, lastmod: Date.today, changefreq: "yearly", priority: 0.4 },
      { url: privacy_url, lastmod: Date.today, changefreq: "yearly", priority: 0.4 },
      { url: new_saju_url, lastmod: Date.today, changefreq: "weekly", priority: 0.9 },
      { url: daily_fortune_url, lastmod: Date.today, changefreq: "daily", priority: 0.95 },
      { url: yearly_fortune_url, lastmod: Date.today, changefreq: "weekly", priority: 0.9 },
      { url: new_compatibility_url, lastmod: Date.today, changefreq: "weekly", priority: 0.9 },
      { url: chat_url, lastmod: Date.today, changefreq: "weekly", priority: 0.85 },
      { url: new_blind_compat_url, lastmod: Date.today, changefreq: "weekly", priority: 0.9 },
      { url: new_solo_destiny_url, lastmod: Date.today, changefreq: "weekly", priority: 0.8 },
      { url: new_dream_url, lastmod: Date.today, changefreq: "weekly", priority: 0.8 },
      { url: zodiac_main_url, lastmod: Date.today, changefreq: "daily", priority: 0.8 },
      { url: tti_fortune_main_url, lastmod: Date.today, changefreq: "daily", priority: 0.8 },
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
    signs = %w[양자리 황소자리 쌍둥이자리 게자리 사자자리 처녀자리 천칭자리 전갈자리 사수자리 염소자리 물병자리 물고기자리]
    signs.each do |sign|
      @pages << { url: zodiac_url(sign: sign), lastmod: Date.today, changefreq: "daily", priority: 0.8 }
    end

    respond_to do |format|
      format.xml
    end
  end
end
