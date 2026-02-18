Rails.application.routes.draw do
  root "home#index"

  # 사주 분석
  get "saju/new", to: "saju#new", as: :new_saju
  post "saju", to: "saju#create", as: :saju
  get "saju/result", to: "saju#show", as: :saju_result

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

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Health
  get "up" => "rails/health#show", as: :rails_health_check
end
