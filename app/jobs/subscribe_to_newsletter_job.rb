class SubscribeToNewsletterJob < ApplicationJob
  queue_as :default

  def perform(email, name = nil)
    return unless Rails.env.production?

    api_url = ENV["JUNK_DRAWER_API_URL"]
    return if api_url.blank?

    uri = URI.parse(api_url)
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")

    body = {
      "email" => email,
      "source" => "bklt"
    }
    body["name"] = name if name.present?

    request.body = body.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    unless response.code == "200"
      raise "Newsletter subscription failed with response code #{response.code} and message #{response.message}"
    end
  end
end
