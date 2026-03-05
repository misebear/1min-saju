# 블라인드 궁합 링크 모델
class BlindCompatLink < ApplicationRecord
  before_create :generate_token
  before_create :set_expiry

  # 매칭 완료 여부
  def matched?
    matched_at.present?
  end

  # 만료 여부
  def expired?
    expires_at < Time.current
  end

  # 사용 가능 여부
  def available?
    !expired? && !matched?
  end

  private

  # URL-safe 8자리 토큰 생성
  def generate_token
    loop do
      self.token = SecureRandom.urlsafe_base64(6) # 약 8자
      break unless BlindCompatLink.exists?(token: token)
    end
  end

  # 7일 후 만료
  def set_expiry
    self.expires_at ||= 7.days.from_now
  end
end
