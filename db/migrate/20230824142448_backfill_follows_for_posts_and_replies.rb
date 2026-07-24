class BackfillFollowsForPostsAndReplies < ActiveRecord::Migration[6.0] # or your Rails version
  def up
    # For each post, create a Follow record for its creator.
    Post.find_each do |post|
      Follow.find_or_create_by(member: post.member, followable: post)
    end

    # For each reply, create a Follow record for its creator on the parent post.
    Reply.find_each do |reply|
      Follow.find_or_create_by(member: reply.member, followable: reply.post)
    end
  end

  def down
    # This is a destructive action, so be careful if you choose to reverse this.
    # For the purpose of this example, we'll leave the down method empty.
    # However, you could potentially delete all the Follow records created by this migration if needed.
  end
end
