class PostMailerPreview < ActionMailer::Preview
  def new_post
    community = Community.find_by_slug("hq")
    post = community.posts.feed_for(nil).first # or however you want to fetch this
    to_member = community.members.where(permission: :admin).first
    PostMailer.new_post(post, to_member)
  end

  def new_reply
    reply = Reply.last # or however you want to fetch this
    to_member = reply.member
    PostMailer.new_reply(reply, to_member)
  end
end
