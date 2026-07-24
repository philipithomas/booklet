require "active_support/concern"

module Passwordlessable
  extend ActiveSupport::Concern

  # Method to generate a signed global ID for passwordless login
  def generate_passwordless_signed_id(duration: 20.minutes)
    signed_id(purpose: "passwordless-login", expires_in: duration)
  end

  # Class method to find a record from the signed ID meant for passwordless login
  module ClassMethods
    def find_by_passwordless_signed_id!(signed_id)
      Member.find_signed!(signed_id, purpose: "passwordless-login")
    end
  end
end
