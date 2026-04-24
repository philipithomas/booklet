# frozen_string_literal: true

# Active Record Encryption keys — used for encrypting sensitive model attributes
# (e.g., VAPID private keys for push notifications).
#
# In production, set these ENV vars to secure random values:
#   rails db:encryption:init
#
# For development and test, we use deterministic defaults so the app
# boots without configuration.

Rails.application.configure do
  config.active_record.encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY", "dev-primary-key-min-12-chars")
  config.active_record.encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "dev-deterministic-key-min-12")
  config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT", "dev-key-derivation-salt")
end
