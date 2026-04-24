class BackfillViews < ActiveRecord::Migration[7.1]
  def change
    Post.find_each do |post|
      View.create!(
        viewable: post,
        member: post.member,
        created_at: post.published_at,
        updated_at: post.published_at
      )
      Rails.logger.info "[Post] Backfilled view for post #{post.id} by member #{post.member.id}"
    end

    Reply.find_each do |reply|
      View.create!(
        viewable: reply.post,
        member: reply.member,
        created_at: reply.created_at,
        updated_at: reply.created_at
      )
      Rails.logger.info "[Reply] Backfilled view for reply #{reply.id} by member #{reply.member.id}"
    end

    Ahoy::Event.where(name: "$view").where.not(user_id: nil).find_each do |event|
      member = Member.find(event.user_id)
      community = member.community
      url_path = URI(event.properties["url"]).path
      if url_path.start_with?("/posts/")
        slug = url_path.split("/").last
        post = community.posts.friendly.find(slug)
        if post
          View.create!(
            viewable: post,
            member: member,
            ahoy_visit_id: event.visit_id,
            created_at: event.time,
            updated_at: event.time
          )
          Rails.logger.info "[$view] Backfilled view for post #{post.id} by member #{member.id}"
        end
      end
    rescue => e
      Rails.logger.error "[$view] Error backfilling view: #{e.message}"
    end
  end
end
