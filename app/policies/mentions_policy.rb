class MentionsPolicy < ApplicationPolicy
  def index?
    member_signed_in?
  end
end
