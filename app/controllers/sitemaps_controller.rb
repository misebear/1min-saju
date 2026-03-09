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

    respond_to do |format|
      format.xml
    end
  end
end
