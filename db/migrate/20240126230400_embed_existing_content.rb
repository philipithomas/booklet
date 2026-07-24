class EmbedExistingContent < ActiveRecord::Migration[7.1]
  def change
    Reply.find_each do |reply|
      reply.enqueue_search_embedding
    end

    Post.find_each do |post|
      post.enqueue_search_embedding
    end

    Member.find_each do |member|
      member.enqueue_search_embedding
    end
  end
end
