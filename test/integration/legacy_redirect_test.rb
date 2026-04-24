require "test_helper"

class LegacyRedirectTest < ActionDispatch::IntegrationTest
  test "should redirect naked bklt.app" do
    host! "bklt.app"
    get "/"
    assert_redirected_to "https://app.booklet.group"
  end

  test "should redirect naked booklet.community" do
    host! "booklet.community"
    get "/"
    assert_redirected_to "https://booklet.group"
  end

  test "should redirect naked booklet.work" do
    host! "booklet.work"
    get "/"
    assert_redirected_to "https://booklet.group"
  end

  test "should redirect www booklet.work" do
    host! "www.booklet.work"
    get "/"
    assert_redirected_to "https://booklet.group"
  end

  test "should redirect subdomain.bklt.app" do
    host! "oimc.bklt.app"
    get "/"
    assert_redirected_to "https://oimc.booklet.group"
  end

  test "should redirect naked bklt.app with path and params" do
    host! "bklt.app"
    get "/foo/bar?key=value"
    assert_redirected_to "https://app.booklet.group/foo/bar?key=value"
  end

  test "should redirect subdomain.bklt.app with path and params" do
    host! "oimc.bklt.app"
    get "/foo/bar?key=value"
    assert_redirected_to "https://oimc.booklet.group/foo/bar?key=value"
  end
end
