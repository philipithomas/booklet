AhoyEmail.default_options[:message] = true

AhoyEmail.subscribers << AhoyEmail::DatabaseSubscriber
AhoyEmail.api = true
AhoyEmail.default_options[:url_options] = {
  host: Rails.configuration.base_host
}
AhoyEmail.preserve_callbacks = [ :store_email_from_token ]

AhoyEmail.save_token = true
AhoyEmail.subscribers << AhoyEmail::MessageSubscriber
