# frozen_string_literal: true

Pay.setup do |config|
  # For use in the receipt/refund/renewal mailers
  config.business_name = ENV.fetch("BUSINESS_NAME", "Booklet")
  config.business_address = ENV.fetch("BUSINESS_ADDRESS", "")
  config.application_name = "Booklet"
  config.support_email = ENV.fetch("SUPPORT_EMAIL", "support@example.com")

  config.default_product_name = "Booklet"
  config.default_plan_name = "booklet"

  config.emails.payment_action_required = false
  config.emails.receipt = false
  config.emails.refund = false
  config.emails.subscription_renewing = false
  config.emails.subscription_trial_will_end = false
  config.emails.subscription_trial_ended = false
end

ActiveSupport.on_load(:pay) do
  Pay::Webhooks.delegator.subscribe "stripe.identity.verification_session.verified", StripeIdentityVerificationSessionVerifiedProcessor.new
end
