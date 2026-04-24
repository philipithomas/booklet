require "active_support/concern"

module Post::Promptable
  extend ActiveSupport::Concern

  class_methods do
    def generate_signed_prompt(prompt)
      verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
      verifier.generate(prompt)
    end

    def verify_signed_prompt(signed_prompt)
      verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
      verifier.verify(signed_prompt)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end
  end
end
