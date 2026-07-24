class BackfillCommunityFollowsOnMembers < ActiveRecord::Migration[7.0]
  def change
    Member.find_each do |member|
      Follow.find_or_create_by(member: member, followable: member.community)
    end
  end
end
