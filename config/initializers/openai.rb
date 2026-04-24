OpenAI.configure do |config|
  if ENV["OPENAI_API_KEY"].present?
    config.access_token = ENV["OPENAI_API_KEY"]
    config.organization_id = ENV["OPENAI_ORG_ID"]
    config.log_errors = !Rails.env.production?
  end
end
