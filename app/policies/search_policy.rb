class SearchPolicy < ApplicationPolicy
  def index?
    member_signed_in?
  end

  def show?
    index?
  end
end
