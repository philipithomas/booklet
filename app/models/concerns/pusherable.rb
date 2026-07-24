require "active_support/concern"

module Pusherable
  extend ActiveSupport::Concern

  included do
    encrypts :vapid_private_key

    def generate_vapid_keys
      return if vapid_public_key.present? && vapid_private_key.present?

      vapid_key = WebPush.generate_key
      update!(vapid_public_key: vapid_key.public_key, vapid_private_key: vapid_key.private_key)
    end
  end
end
