class ModerationMailerPreview < ActionMailer::Preview
  def post_quarantined_email
    hq = Community.find_by_slug("hq")
    moderation = ModerationScore.new(flagged: true, moderatable: hq.posts.last, categories: { sexual: true, harassment: true, other: false })
    ModerationMailer.post_quarantined_email(moderation)
  end

  def reply_quarantined_email
    hq = Community.find_by_slug("hq")
    post = hq.posts.last
    moderation = ModerationScore.new(flagged: true, moderatable: post.replies.last, categories: { sexual: true, harassment: true, other: false })
    ModerationMailer.reply_quarantined_email(moderation)
  end
end
