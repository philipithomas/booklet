# frozen_string_literal: true

module ServiceAvailable
  extend self

  def openai?
    ENV["OPENAI_API_KEY"].present?
  end

  def chroma?
    ENV["CHROMA_HOST"].present?
  end

  def postmark?
    ENV["POSTMARK_API_TOKEN"].present?
  end

  def stripe?
    Rails.configuration.multiuser_mode
  end

  def hcaptcha?
    ENV["HCAPTCHA_SITE_KEY"].present? && ENV["HCAPTCHA_SECRET_KEY"].present?
  end

  def fly?
    ENV["FLY_API_TOKEN"].present?
  end
end
