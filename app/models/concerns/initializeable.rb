require "active_support/concern"

module Initializeable
  extend ActiveSupport::Concern

  def initials
    initials = NameOfPerson::PersonName.full(name).initials.upcase
    return "" if initials.blank?
    return initials[0] if initials.length == 1
    initials[0] + initials[initials.length - 1] # Otherwise, first and last initials
  end
end
