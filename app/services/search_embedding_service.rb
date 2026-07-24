class SearchEmbeddingService
  def initialize(search)
    @search = search
    @member = @search.member
    @community = @member.community

    @client = OpenAI::Client.new
    @client.extra_headers["Helicone-Property-Model"] = "SearchEmbeddingService"
    @client.extra_headers["Helicone-Property-Environment"] = Rails.env
    @client.extra_headers["Helicone-Property-Community-Slug"] = @community.slug
    @client.extra_headers["Helicone-Property-Member-ID"] = @member.id.to_s
    @client.extra_headers["Helicone-Property-Member-Email"] = @member.email

    @client.extra_headers["Helicone-User-Id"] = @member.community.id.to_s
  end

  def call
    return test_response if Rails.env.test?

    text = @search.query

    model = "text-embedding-3-large"
    max_tokens = 8191

    tokenizer = Tiktoken.encoding_for_model(model)

    tokens = tokenizer.encode(text)
    while tokens.size > max_tokens
      sentences = text.split(". ")
      sentences.pop # Remove the last sentence until it fits within the token limit
      text = sentences.join(". ")
      tokens = tokenizer.encode(text)
    end

    res = @client.embeddings(parameters: {
      model: model,
      input: tokenizer.decode(tokens)
    })

    res.dig("data", 0, "embedding")
  end

  def test_response
    test_vector
  end

  def test_vector
    3072.times.map { rand(-1.0..1.0) }
  end
end
