class PostPolicy < ApplicationPolicy
  def index?
    raise "policy expected community" unless @record.is_a?(Community)
    return member_signed_in? if @record.visibility_private?
    true
  end

  def recommended?
    member_signed_in?
  end

  def show?
    # Check if the record is quarantined
    if @record.quarantined_at? || @record.member.quarantined_at?      # Return false if there's no member
      return false unless @member

      # Return true if the member is the author of the record or is a manager/admin
      return true if @member.id == @record.member_id || @member.manager_or_admin?
      return false
    end

    # If the community is private, return true if a member is signed in, else return false
    return member_signed_in? if @record.community.visibility_private?
    @record.published?
  end

  def edit?
    return false unless member_signed_in?
    @member.id == @record.member_id || @member.manager_or_admin?
  end

  def update?
    edit?
  end

  def destroy?
    return false unless member_signed_in?
    return true if @member.manager_or_admin?
    @member.id == @record.member_id
  end

  def create?
    member_signed_in?
  end

  def new?
    create?
  end
end
