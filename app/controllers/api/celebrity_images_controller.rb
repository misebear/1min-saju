# frozen_string_literal: true

module Api
  class CelebrityImagesController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [ :create ]

    # POST /api/celebrity_images
    # 유명인 이름 배열을 받아 사진 URL 반환 (없으면 위키에서 검색 후 DB 캐시)
    def create
      names = params[:names] || []
      names = names.first(10) # 최대 10명 제한

      result = {}
      names.each do |name|
        result[name] = CelebrityImageService.fetch_image(name)
      end

      render json: result
    end
  end
end
