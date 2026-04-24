# frozen_string_literal: true

Rails.application.configure do
  # Application mode: SOLO (single community, no subdomains) or MULTIUSER (multi-tenant SaaS)
  config.app_mode = ENV.fetch("APP_MODE", "SOLO").upcase
  config.solo_mode = config.app_mode == "SOLO"
  config.multiuser_mode = config.app_mode == "MULTIUSER"

  # Domain configuration
  default_host = if Rails.env.production?
    ENV.fetch("BASE_HOST", "localhost")
  else
    "localtest.me"
  end

  config.app_apex_host = ENV.fetch("BASE_HOST", default_host)

  if config.solo_mode
    # Solo mode: everything runs on a single host, no subdomains
    config.base_host = config.app_apex_host
    config.cdn_host = config.app_apex_host
    config.signup_host = config.app_apex_host
    config.marketing_host = config.app_apex_host
    config.editor_host = config.app_apex_host
    config.index_host = config.app_apex_host
    config.api_host = config.app_apex_host
  else
    # Multiuser mode: subdomain-based routing
    config.base_host = "app.#{config.app_apex_host}"
    config.cdn_host = "delivery.#{config.app_apex_host}"
    config.signup_host = "new.#{config.app_apex_host}"
    config.marketing_host = "www.#{config.app_apex_host}"
    config.editor_host = "editor.#{config.app_apex_host}"
    config.index_host = "index.#{config.app_apex_host}"
    config.api_host = "api.#{config.app_apex_host}"
  end

  # Allow all hosts in development/test (subdomains via localtest.me)
  config.hosts.clear unless Rails.env.production?

  # URL options
  if Rails.env.production?
    config.action_controller.default_url_options = { host: config.base_host, protocol: "https" }
    config.action_mailer.default_url_options = { host: config.base_host, protocol: "https" }
  else
    config.action_controller.default_url_options = { host: config.base_host, port: 3000 }
    config.action_mailer.default_url_options = { host: config.base_host, port: 3000 }
  end

  # Asset host (production multiuser only)
  if Rails.env.production? && config.multiuser_mode
    config.asset_host = "https://#{config.cdn_host}"
  end

  # Email configuration
  config.default_email_from = ENV.fetch("DEFAULT_EMAIL_FROM", "hello@booklet.group")
  config.admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
  config.support_email = ENV.fetch("SUPPORT_EMAIL", "support@example.com")
end
