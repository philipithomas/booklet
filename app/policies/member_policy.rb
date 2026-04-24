class MemberPolicy < ApplicationPolicy
  def new?
    create?
  end

  def create?
    return false unless member_signed_in?
    @member.manager_or_admin?
  end

  def index?
    member_signed_in? && @record.directory_enabled?
  end

  def index_all?
    return false unless member_signed_in?
    @member.manager_or_admin?
  end

  def show?
    return false unless member_signed_in?

    if @record.quarantined_at?
      return false unless @member

      # Return true if the member is the author of the record or is a manager/admin
      return true if @member.id == @record.id || @member.manager_or_admin?
      return false
    end

    unless @member.manager? || @member.admin?
      return false unless @record.confirmed?
      return false if @record.invited_to_sign_up?
    end

    true
  end

  def edit?
    return false unless show?
    return true if @member.admin?
    return true if @member.manager? && !@record.admin?

    @member.id == @record.id
  end

  def update?
    edit?
  end

  def destroy?
    return false unless @member
    return false if @record.admin?
    @member.admin?
  end
end
