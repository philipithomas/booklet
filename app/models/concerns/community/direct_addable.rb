module Community::DirectAddable
  extend ActiveSupport::Concern

  def members_directly_added(current_member = nil)
    if current_member&.person_id
      # count by verified member
      person = Person.find(current_member.person_id)
      member_ids = person.members.pluck(:id)
      Ahoy::Event.where_event(:member_directly_added, user_id: member_ids).count
    else
      # count in community
      Ahoy::Event.where_event(:member_directly_added, community_id: id).count
    end
  end

  def member_direct_add_limit(current_member = nil)
    if current_member&.person_id
      person = Person.find(current_member.person_id)
      person.max_member_direct_adds
    else
      max_direct_add_limit = 10
      members.active_admins.each do |admin|
        if admin.person
          max_direct_add_limit = admin.person.max_member_direct_adds if admin.person.max_member_direct_adds > max_direct_add_limit
        end
      end
      max_direct_add_limit
    end
  end

  def member_directly_added!(current_member = nil, added_member = nil, current_visit = nil)
    Ahoy::Event.create(name: "member_directly_added", properties: { community_id: id, adder_id: current_member&.id, added_member_id: added_member&.id }, visit: current_visit, time: Time.now, user: current_member)
  end

  def can_direct_add_member?(current_member = nil)
    if current_member&.person_id
      person = Person.find(current_member.person_id)
      limit = person.max_member_direct_adds
    else
      limit = member_direct_add_limit(current_member)
    end
    members_directly_added(current_member) < limit
  end
end
