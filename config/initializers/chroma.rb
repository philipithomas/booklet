require "chroma-db"

if ENV["CHROMA_HOST"].present?
  Chroma.connect_host = ENV["CHROMA_HOST"]
  Chroma.api_key = ENV["CHROMA_API_KEY"]
  Chroma.tenant = ENV["CHROMA_TENANT"]
  Chroma.database = ENV["CHROMA_DATABASE"]

  Chroma.logger = Logger.new($stdout)
  Chroma.log_level = Rails.env.development? ? Chroma::LEVEL_DEBUG : Chroma::LEVEL_ERROR
end
