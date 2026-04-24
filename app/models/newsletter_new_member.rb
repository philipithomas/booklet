# == Schema Information
#
# Table name: newsletter_new_members
#
#  id            :bigint           not null, primary key
#  member_id     :bigint           not null
#  newsletter_id :bigint           not null
#
# Indexes
#
#  index_newsletter_new_members_on_member_id      (member_id)
#  index_newsletter_new_members_on_newsletter_id  (newsletter_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#  fk_rails_...  (newsletter_id => newsletters.id)
#
class NewsletterNewMember < ApplicationRecord
  belongs_to :newsletter
  belongs_to :member
end
