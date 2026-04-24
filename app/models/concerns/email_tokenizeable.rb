require "active_support/concern"

module EmailTokenizeable
  extend ActiveSupport::Concern

  # Used for identifying members from their clicks for sign-in purposes and unsubscribes

  # Method to generate a signed token for the email
  def generate_email_signed_token
    signed_id(purpose: "email-token")
  end

  # Class method to decrypt and retrieve the email from the signed token
  module ClassMethods
    def find_by_email_signed_token(signed_id)
      Member.find_signed!(signed_id, purpose: "email-token")
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end
  end
end
