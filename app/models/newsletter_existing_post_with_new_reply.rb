# == Schema Information
#
# Table name: newsletter_existing_posts_with_new_replies
#
#  id            :bigint           not null, primary key
#  newsletter_id :bigint           not null
#  post_id       :bigint           not null
#
# Indexes
#
#  index_newsletter_existing_posts_new_replies_on_newsletter_id  (newsletter_id)
#  index_newsletter_existing_posts_with_new_replies_on_post_id   (post_id)
#
# Foreign Keys
#
#  fk_rails_...  (newsletter_id => newsletters.id)
#  fk_rails_...  (post_id => posts.id)
#
class NewsletterExistingPostWithNewReply < ApplicationRecord
  self.table_name = "newsletter_existing_posts_with_new_replies"
  belongs_to :newsletter
  belongs_to :post
end
