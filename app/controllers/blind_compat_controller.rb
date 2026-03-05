# 카톡 블라인드 궁합 컨트롤러
class BlindCompatController < ApplicationController
  # A: 내 생일 입력 폼
  def new
  end

  # A: 링크 생성
  def create
    birth_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)

    link = BlindCompatLink.create!(
      person1_birth_date: birth_date,
      person1_hour: params[:hour].to_i,
      person1_gender: params[:gender] || "남",
      person1_name: params[:nickname].to_s.strip.presence || "익명"
    )

    @token = link.token
    @share_url = blind_invite_url(token: @token)
    render :created
  rescue => e
    Rails.logger.error("블라인드 궁합 링크 생성 실패: #{e.message}")
    redirect_to new_blind_compat_path, alert: "다시 시도해줘!"
  end

  # B: 링크 클릭 시 랜딩
  def invite
    @link = BlindCompatLink.find_by(token: params[:token])

    unless @link
      redirect_to root_path, alert: "존재하지 않는 링크야!"
      return
    end

    if @link.expired?
      redirect_to root_path, alert: "만료된 링크야! 새 링크를 받아봐~"
      return
    end

    # 이미 매칭됐으면 결과로 이동
    if @link.matched?
      redirect_to blind_result_path(token: @link.token)
      return
    end

    @person1_name = @link.person1_name.presence || "누군가"
  end

  # B: 생일 입력 후 매칭
  def match
    @link = BlindCompatLink.find_by(token: params[:token])

    unless @link&.available?
      redirect_to root_path, alert: "이미 매칭됐거나 만료된 링크야!"
      return
    end

    birth_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)

    @link.update!(
      person2_birth_date: birth_date,
      person2_hour: params[:hour].to_i,
      person2_gender: params[:gender] || "여",
      person2_name: params[:nickname].to_s.strip.presence || "익명",
      matched_at: Time.current
    )

    redirect_to blind_result_path(token: @link.token)
  rescue => e
    Rails.logger.error("블라인드 궁합 매칭 실패: #{e.message}")
    redirect_to blind_invite_path(token: params[:token]), alert: "다시 시도해줘!"
  end

  # 궁합 결과 (A/B 모두)
  def result
    @link = BlindCompatLink.find_by(token: params[:token])

    unless @link&.matched?
      redirect_to root_path, alert: "아직 매칭이 안 됐어!"
      return
    end

    # 사주 분석
    @person1 = SajuEngine.full_analysis(@link.person1_birth_date, @link.person1_hour, @link.person1_gender)
    @person2 = SajuEngine.full_analysis(@link.person2_birth_date, @link.person2_hour, @link.person2_gender)
    @compatibility = SajuEngine.compatibility(@person1, @person2)

    @name1 = @link.person1_name.presence || "A"
    @name2 = @link.person2_name.presence || "B"
    @token = @link.token
  end
end
