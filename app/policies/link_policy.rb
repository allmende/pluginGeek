class LinkPolicy < ApplicationPolicy
  alias_method :link, :record

  def submitter
    submitter = link && link.submitter
    submitter == user
  end

  def index?
    user
  end

  def create?
    user
  end

  def update?
    user
  end

  def destroy?
    submitter || staff
  end
end
