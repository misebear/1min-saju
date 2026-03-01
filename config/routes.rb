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
