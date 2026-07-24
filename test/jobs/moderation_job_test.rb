require "test_helper"

class ModerationJobTest < ActiveJob::TestCase
  def setup
    @post = posts(:post)
  end

  test "moderation job enqueues on post creation" do
    assert_difference "ModerationScore.count", 1 do
      ModerationJob.perform_now("Post", @post.id, @post.updated_at)
    end

    moderation_score = @post.moderation_scores.last
    assert moderation_score.present?
    assert_equal @post.updated_at, moderation_score.content_updated_at
    assert_not moderation_score.flagged?
  end
end
