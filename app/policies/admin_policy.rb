class AdminPolicy < ApplicationPolicy
  def index?
    show?
  end

  def create?
    show?
  end

  def new?
    show?
  end

  def show?
    @member&.admin?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end
end
