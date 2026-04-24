require "test_helper"

class CommunityHostsTest < ActionDispatch::IntegrationTest
  def setup
    @community = communities(:lab)
  end

  test "host is accessible" do
    get new_member_session_url(host: "lab.localtest.me")
    assert_response :success
  end

  test "invalid host returns 404" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get posts_url(host: "invalid.localtest.me")
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      get posts_url(host: "invalid.fbi.com")
    end
  end
end
