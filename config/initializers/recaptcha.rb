if ENV["HCAPTCHA_SITE_KEY"].present? && ENV["HCAPTCHA_SECRET_KEY"].present?
  Recaptcha.configure do |config|
    config.site_key = ENV["HCAPTCHA_SITE_KEY"]
    config.secret_key = ENV["HCAPTCHA_SECRET_KEY"]
    config.verify_url = "https://hcaptcha.com/siteverify"
    config.api_server_url = "https://hcaptcha.com/1/api.js"
    config.response_limit = 100_000
  end
end
