# frozen_string_literal: true

require "test_helper"

class PremiumControllerTest < ActionDispatch::IntegrationTest
  test "premium page explains subscription ad removal reward details and chatbot" do
    get premium_path

    assert_response :success
    assert_select "h1", text: /프리미엄/
    assert_includes response.body, "광고 제거"
    assert_includes response.body, "광고 보면 상세 풀이"
    assert_includes response.body, "AI 사주 챗봇"
    assert_includes response.body, "오늘운세 알림"
    assert_includes response.body, "사주 기록 저장"
    assert_select "a[href=?]", chat_path
  end
end
