# frozen_string_literal: true

require "test_helper"

class NavigationLayoutTest < ActionDispatch::IntegrationTest
  test "menu page renders grouped app links" do
    get app_menu_path

    assert_response :success
    assert_select "h1", text: "궁금한 풀이를 골라봐요"
    assert_select "a[href=?]", new_saju_path, text: /사주풀이/
    assert_select "a[href=?]", new_compatibility_path, text: /궁합/
    assert_select "a[href=?]", new_dream_path, text: /꿈해몽/
    assert_select "a[href=?]", chat_path, text: /AI 챗봇/
    assert_select "a[href=?]", premium_path, text: /프리미엄/
  end

  test "bottom nav marks home active" do
    get root_path

    assert_response :success
    assert_select ".bottom-nav .nav-item[data-nav-section=home].active", count: 1
  end

  test "bottom nav marks saju active" do
    get new_saju_path

    assert_response :success
    assert_select ".bottom-nav .nav-item[data-nav-section=saju].active", count: 1
  end

  test "bottom nav marks fortune active" do
    get daily_fortune_path

    assert_response :success
    assert_select ".bottom-nav .nav-item[data-nav-section=fortune].active", count: 1
  end

  test "bottom nav marks chat active" do
    get chat_path

    assert_response :success
    assert_select ".bottom-nav .nav-item[data-nav-section=chat].active", count: 1
  end

  test "bottom nav marks more active" do
    get app_menu_path

    assert_response :success
    assert_select ".bottom-nav .nav-item[data-nav-section=more].active", count: 1
  end

  test "saju story cta links use ad gate and keep tap overlay behind content" do
    post saju_path, params: {
      year: 1990,
      month: 5,
      day: 15,
      hour: 11,
      city: "서울",
      gender: "남"
    }
    follow_redirect!

    assert_response :success
    assert_select ".story-tap-area[aria-hidden=true]", count: 1
    assert_select ".sc-tap-hint", text: /왼쪽 이전/
    assert_select ".story-ad-overlay#storyAdOverlay", count: 1
    assert_select "a.sc-cta-btn[data-story-ad-link=true][href=?]", daily_fortune_path, text: /오늘의 운세/
    assert_select "a.sc-cta-btn[data-story-ad-link=true][href=?]", new_compatibility_path, text: /궁합/
    assert_select "a.sc-cta-btn[data-story-ad-link=true][href=?]", chat_path, text: /AI 챗봇/
  end
end
