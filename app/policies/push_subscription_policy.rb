class PushSubscriptionPolicy < ApplicationPolicy
  def create?
    member_signed_in?
  end
end
