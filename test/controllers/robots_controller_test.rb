require "test_helper"

class RobotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    requires_multiuser_mode!
    @community = communities(:lab)
  end

  test "robots.txt should be available on new community page and disallow" do
    get robots_url(host: "new.fbi.com")
    assert_response :success
    assert @response.body.include?("Disallow: /")
  end

  test "robots.txt should be available on a public community page and allow" do
    @community.update!(visibility: :public)
    get robots_url(host: @community.host)
    assert_response :success
    assert @response.body.include?("Allow: /")
    assert_not @response.body.include?("Disallow: /\n")
  end

  test "robots.txt should be available on a private community page and disallow" do
    @community.update!(visibility: :private)
    get robots_url(host: @community.host)
    assert_response :success
    assert @response.body.include?("Disallow: /")
    assert_not @response.body.include?("Allow: /")
  end

  test "robots.txt should be available on a unlisted community page and disallow" do
    @community.update!(visibility: :unlisted)
    get robots_url(host: @community.host)
    assert_response :success
    assert @response.body.include?("Disallow: /")
    assert_not @response.body.include?("Allow: /")
  end
end
