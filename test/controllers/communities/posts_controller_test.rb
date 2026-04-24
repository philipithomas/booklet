class Communities::PostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @community = communities(:lab)
    @post = posts(:post)
    @member = members(:member)
    sign_in @member
  end

  test "should enqueue view after showing post" do
    assert_enqueued_with(job: CreateViewJob, args: [ @member.id, @post, nil ]) do
      get post_url(@post, host: @community.host)
    end
  end
end
