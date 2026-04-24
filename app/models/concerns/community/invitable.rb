module Community::Invitable
  extend ActiveSupport::Concern

  def members_invited_in_last_24_hours
    Ahoy::Event.where_event(:member_invitation_created, community_id: id).where("time > ?", 24.hours.ago).count
  end

  def member_invited!(current_member = nil, invited_member = nil, current_visit = nil)
    Ahoy::Event.create!(name: "member_invitation_created", properties: { community_id: id, inviter_id: current_member&.id, invited_member_id: invited_member&.id }, visit: current_visit, time: Time.now, user: current_member)
  end
end
