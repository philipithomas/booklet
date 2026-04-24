require "test_helper"

class CommunitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @community = communities(:lab)
  end

  test "community should be available on community page" do
    get new_member_session_url(host: @community.host)
    assert_response :success
    assert @response.body.include?(@community.name)
    assert_match(/<title>.*Laboratory.*<\/title>/, @response.body)
  end

  test "when custom domain is not verified, it should still return the community" do
    Domain.create!(community: @community, domain: "lab.fbi.com", verified: false)
    get new_member_session_url(host: "lab.fbi.com")
    assert_response :success
    assert_match(/<title>.*Laboratory.*<\/title>/, @response.body)
  end

  test "when domain is not verified, then app host should not redirect to community" do
    Domain.create!(community: @community, domain: "lab.fbi.com", verified: false)
    get new_member_session_url(host: "lab.localtest.me")
    assert_response :success
    assert_match(/<title>.*Laboratory.*<\/title>/, @response.body)
  end

  test "when domain is verified, host should be community host" do
    Domain.create!(community: @community, domain: "lab.fbi.com", verified: true)
    get new_member_session_url(host: "lab.fbi.com")
    assert_response :success
    assert_match(/<title>.*Laboratory.*<\/title>/, @response.body)
  end

  test "when domain is verified, app host should redirect to community" do
    Domain.create!(community: @community, domain: "lab.fbi.com", verified: true)
    assert_equal "lab.fbi.com", @community.host
    get posts_url(host: "lab.localtest.me")
    assert_redirected_to "http://lab.fbi.com/"
  end

  test "when domain with redirect_for_name is accessed, it should redirect to community" do
    Domain.create!(community: @community, domain: "lab.fbi.com", verified: true)
    Domain.create!(community: @community, domain: "www.lab.fbi.com", redirect_for_name: "lab.fbi.com", verified: true)
    get posts_url(host: "www.lab.fbi.com")
    assert_redirected_to "http://lab.fbi.com/"
  end
end
