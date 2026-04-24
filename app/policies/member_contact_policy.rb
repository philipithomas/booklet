class MemberContactPolicy < ApplicationPolicy
  def new?
    return false unless member_signed_in?
    @record.community.email_visibility_protected? && MemberPolicy.new(@member, @record).show?
  end

  def create?
    new?
  end
end
