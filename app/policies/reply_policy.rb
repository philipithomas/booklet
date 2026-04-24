class ReplyPolicy < ApplicationPolicy
  def index?
    raise "policy expected post" unless @record.is_a?(Post)
    return member_signed_in? if @record.community.visibility_private?
    true
  end

  def show?
    # Check if the record is quarantined
    if @record.quarantined_at? || @record.member.quarantined_at?

      # Return false if there's no member
      return false unless @member

      # Return true if the member is the author of the record or is a manager/admin
      return true if @member.id == @record.member_id || @member.manager_or_admin?
      return false
    end

    return member_signed_in? if @record.post.community.visibility_private?
    true
  end

  def create?
    return false if @record.quarantined_at? && !(@member.id == @record.member_id || @member.manager_or_admin?)
    member_signed_in?
  end

  def edit?
    return false unless member_signed_in?
    @member.id == @record.member_id
  end

  def update?
    edit?
  end

  def destroy?
    return false unless member_signed_in?
    return true if @member.manager_or_admin?
    @member.id == @record.member_id
  end
end
