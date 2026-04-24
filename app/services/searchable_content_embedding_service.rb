class SearchableContentEmbeddingService
  def initialize(model)
    @model = model
    @community = model.community

    @client = OpenAI::Client.new
    @client.extra_headers["Helicone-Property-Model"] = "SearchableContentEmbeddingService"
    @client.extra_headers["Helicone-Property-Environment"] = Rails.env
    @client.extra_headers["Helicone-Property-Community-Slug"] = @community.slug
    @client.extra_headers["Helicone-User-Id"] = @community.id.to_s
  end

  def call
    return test_response if Rails.env.test?

    text = extract_text(@model)
    max_tokens = 8000

    while OpenAI.rough_token_count(text) > max_tokens
      text = text[0...-1] # Trim the text from the end until it fits within the token limit
    end

    res = @client.embeddings(parameters: {
      model: "text-embedding-3-large",
      input: text
    })

    embedding = res.dig("data", 0, "embedding")
    Rails.logger.info "SearchableContentEmbeddingService for community #{@community.id}: #{@model.class} #{@model.id}: #{res}"

    [ embedding, text ]
  end

  private

  def extract_text(model)
    case model
    when Post
      "#{model.title}\n#{model.body.to_plain_text}"
    when Member
      "#{model.name}\n#{model.about.to_plain_text}"
    when Reply
      model.body.to_plain_text
    else
      raise ArgumentError, "Unknown model type: #{model.class}"
    end
  end

  def test_vector
    3072.times.map { rand(-1.0..1.0) }
  end
end
