source "https://rubygems.org"

ruby "3.3.5"

# Explicitly specify stringio version to avoid installation errors
gem "stringio", "~> 3.0.5"

# core
gem "rails", "~> 7.2.3", ">= 7.2.3.1"
gem "tzinfo-data", ">= 1.2016.7"  # Don't rely on OSX/Linux timezone data
gem "sprockets-rails"
gem "puma", "~> 7.2"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bootsnap", require: false
gem "pg", "~> 1.5"
gem "solid_queue", "~> 0.3.2"
gem "mission_control-jobs", "~> 0.2.1"
gem "jsbundling-rails", "~> 1.2"

# forms
gem "simple_form", "~> 5.2"
gem "simple_form_tailwind_css", "~> 1.0"

# auth
gem "devise", "~> 5.0", ">= 5.0.4"
gem "devise-i18n", "~> 1.12"
gem "devise_invitable", "~> 2.0"

# images
gem "image_processing", "~> 1.2"
gem "aws-sdk-s3", "~> 1.151"
gem "ruby-vips", "~> 2.1"

# css
gem "tailwindcss-rails", "~> 2.3"

# seo
gem "meta-tags", "~> 2.21"
gem "grover", "~> 1.1"

# utilities
gem "name_of_person", "~> 1.1"
gem "wcag_color_contrast", "~> 0.1.0"
gem "rails-i18n", "~> 7.0"
gem "countries", "~> 5.7"
gem "safely_block", "~> 0.4.0"
gem "httparty", "~> 0.23"
gem "lograge", "~> 0.14.0"
gem "pagy", "~> 8.4"
gem "nokogiri", "~> 1.18"
gem "wicked", "~> 2.0"
gem "memoist", "~> 0.16.2"
gem "friendly_id", "~> 5.5"

# payments
gem "pay", "~> 7.1"
gem "stripe", "~> 12"

# email
gem "postmark-rails", "~> 0.22.1"
gem "premailer-rails", "~> 1.12"

# security
gem "honeypot-captcha", "~> 1.0"
gem "rack-attack", "~> 6.7"
gem "audited", "~> 5.3"
gem "authtrail", "~> 0.5.0"
gem "recaptcha", "~> 5.16"

# authz
gem "pundit", "~> 2.3"

# enrichment
gem "whois", "~> 5.1"
gem "whois-parser", "~> 2.0"
gem "platform_agent", "~> 1.0"
gem "truemail", "~> 3.3"

# monitoring
gem "health_check", "~> 3.1"
gem "pghero", "~> 3.3"
gem "notable", "~> 0.5.2"

# ai
gem "ruby-openai", "~> 7.0"
gem "strong_migrations", "~> 1.8"
gem "pgvector", "~> 0.2.2"
gem "neighbor", "~> 0.3.2"
gem "tiktoken_ruby", "~> 0.0.9"
gem "chroma-db", "~> 0.8.2"

# push
gem "web-push", "~> 3.0"

# analytics
gem "geocoder", "~> 1.8"
gem "maxminddb", "~> 0.1.22"
gem "groupdate", "~> 6.4"
gem "chartkick", "~> 5.0"
gem "ahoy_matey", "~> 4.2"
gem "ahoy_email", "~> 2.2"
gem "blazer", "~> 3.0"

# api
gem "bcrypt", "~> 3.1"
gem "rspec-rails", "~> 6.1"
gem "rswag", "~> 2.13"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "brakeman", "~> 6.1"
  gem "annotate", "~> 3.2"
  gem "faker", "~> 3.3"
  gem "solargraph", "~> 0.50.0", require: false
  gem "i18n-tasks", "~> 1.0.14"
  gem "bundler-audit", "~> 0.9.1"
  gem "rubocop-rails-omakase", require: false
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
  gem "i18n-debug", "~> 1.2"
  gem "dockerfile-rails", ">= 1.2"
  gem "letter_opener"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

group :production do
  gem "cloudflare-rails", "~> 6.0"
end

gem "heroicon", "~> 1.0"

gem "solid_cable", "~> 3.0"
