Rails.application.routes.draw do
  root "home#index"

  # 사주 분석
  get "saju/new", to: "saju#new", as: :new_saju
  post "saju", to: "saju#create", as: :saju
  get "saju/result", to: "saju#show", as: :saju_result
  get "saju/history", to: "saju#history", as: :saju_history

  # 운세
  get "fortunes/daily", to: "fortunes#daily", as: :daily_fortune
  get "fortunes/yearly", to: "fortunes#yearly", as: :yearly_fortune

  # 블라인드 궁합 (카톡 바이럴)
  get "blind/new", to: "blind_compat#new", as: :new_blind_compat
  post "blind", to: "blind_compat#create", as: :blind_compat
  get "blind/:token", to: "blind_compat#invite", as: :blind_invite
  post "blind/:token/match", to: "blind_compat#match", as: :blind_match
  get "blind/:token/result", to: "blind_compat#result", as: :blind_result

  # 궁합
  get "compatibility/new", to: "compatibility#new", as: :new_compatibility
  post "compatibility", to: "compatibility#create", as: :compatibility
  get "compatibility/result", to: "compatibility#show", as: :compatibility_result

  # AI 챗봇
  get "chat", to: "chat#show", as: :chat
  post "chat/message", to: "chat#message", as: :chat_message

  # 나는솔로 인연 풀이
  get "solo_destiny/new", to: "solo_destiny#new", as: :new_solo_destiny
  post "solo_destiny", to: "solo_destiny#create", as: :solo_destiny
  get "solo_destiny/result", to: "solo_destiny#show", as: :solo_destiny_result

  # 꿈해몽
  get "dreams/new", to: "dreams#new", as: :new_dream
  post "dreams", to: "dreams#create", as: :dreams
  get "dreams/result", to: "dreams#show", as: :dream_result

  # 별자리 운세
  get "zodiac", to: "zodiac#show", as: :zodiac

  # 택일 (살풀이)
  get "auspicious_dates/new", to: "auspicious_dates#new", as: :new_auspicious_date
  post "auspicious_dates", to: "auspicious_dates#create", as: :auspicious_dates
  get "auspicious_dates/result", to: "auspicious_dates#show", as: :auspicious_date_result

  # 토정비결
  get "tojeong/new", to: "tojeong#new", as: :new_tojeong
  post "tojeong", to: "tojeong#create", as: :tojeong
  get "tojeong/result", to: "tojeong#show", as: :tojeong_result

  # 내일/지정일 운세
  get "fortunes/tomorrow", to: "fortunes#tomorrow", as: :tomorrow_fortune
  get "fortunes/specific", to: "fortunes#specific_form", as: :specific_fortune_form
  post "fortunes/specific", to: "fortunes#specific", as: :specific_fortune

  # 띠운세
  get "tti", to: "tti_fortune#show", as: :tti_fortune

  # 타로
  get "tarot/new", to: "tarot#new", as: :new_tarot
  post "tarot", to: "tarot#create", as: :tarot
  get "tarot/result", to: "tarot#show", as: :tarot_result

  # 심리풀이
  get "psychology/new", to: "psychology#new", as: :new_psychology
  post "psychology", to: "psychology#create", as: :psychology
  get "psychology/result", to: "psychology#show", as: :psychology_result

  # 전생운
  get "past_life/new", to: "past_life#new", as: :new_past_life
  post "past_life", to: "past_life#create", as: :past_life
  get "past_life/result", to: "past_life#show", as: :past_life_result

  # 탄생석
  get "birthstone", to: "birthstone#show", as: :birthstone

  # 취업운
  get "career/new", to: "career#new", as: :new_career
  post "career", to: "career#create", as: :career
  get "career/result", to: "career#show", as: :career_result

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # API
  namespace :api do
    resources :celebrity_images, only: [ :create ]
  end

  # Health
  get "up" => "rails/health#show", as: :rails_health_check
end
