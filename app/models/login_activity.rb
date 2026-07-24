# == Schema Information
#
# Table name: login_activities
#
#  id             :bigint           not null, primary key
#  city           :string
#  context        :string
#  country        :string
#  failure_reason :string
#  host           :string
#  identity       :string
#  ip             :string
#  latitude       :float
#  longitude      :float
#  referrer       :text
#  region         :string
#  scope          :string
#  strategy       :string
#  success        :boolean          default(FALSE), not null
#  user_agent     :text
#  user_type      :string
#  created_at     :datetime
#  community_id   :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_login_activities_on_community_id  (community_id)
#  index_login_activities_on_identity      (identity)
#  index_login_activities_on_ip            (ip)
#  index_login_activities_on_user          (user_type,user_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
class LoginActivity < ApplicationRecord
  belongs_to :user, polymorphic: true, optional: true
end
