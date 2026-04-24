require "active_support/concern"

module Unsubscribeable
  extend ActiveSupport::Concern

  # Method to generate a signed global ID for unsubscribing
  def generate_unsubscribe_signed_id
    signed_id(purpose: "unsubscribe")
  end

  # Class method to find a record from the signed ID meant for unsubscribing
  module ClassMethods
    def find_by_unsubscribe_signed_id!(signed_id)
      Follow.find_signed!(signed_id, purpose: "unsubscribe")
    end
  end
end
