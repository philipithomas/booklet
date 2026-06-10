# frozen_string_literal: true

# Active Record Encryption keys — used for encrypting sensitive model attributes
# (e.g., VAPID private keys for push notifications).
#
# In production these ENV vars are required. Generate values with:
#   rails db:encryption:init
#
# Development and test use deterministic defaults so the app boots without
# configuration. Production must not: falling back to these publicly known
# keys would make the encrypted data readable by anyone.

Rails.application.configure do
  if Rails.env.production?
    config.active_record.encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY")
    config.active_record.encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY")
    config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT")
  else
    config.active_record.encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY", "dev-primary-key-min-12-chars")
    config.active_record.encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "dev-deterministic-key-min-12")
    config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT", "dev-key-derivation-salt")
  end
end
