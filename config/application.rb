require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bklt
  class Application < Rails::Application
    config.load_defaults 7.0

    config.active_job.queue_adapter = :solid_queue

    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]
    config.i18n.default_locale = "en-US"

    postmark_token = ENV["POSTMARK_API_TOKEN"]
    if postmark_token.present?
      config.action_mailer.delivery_method = :postmark
      config.action_mailer.postmark_settings = { api_token: postmark_token }
    end

    config.exceptions_app = ->(env) {
      ErrorsController.action(:show).call(env)
    }

    config.autoload_paths << Rails.root.join("lib")

    config.active_record.strict_loading_by_default = true
    config.active_record.action_on_strict_loading_violation = :log

    config.generators do |g|
      g.stylesheets false
      g.helper false
      g.javascripts false
      g.jbuilder false
    end
    # https://stackoverflow.com/questions/53629110/how-to-display-svg-as-images-with-active-storage
    ActiveStorage::Engine.config
      .active_storage
      .content_types_to_serve_as_binary
      .delete("image/svg+xml")

    config.middleware.insert_after ActionDispatch::Static, Rack::Deflater

    config.booklet_brand_color = "#4D3DF7"

    config.active_record.query_log_tags_enabled = true
  end
end
