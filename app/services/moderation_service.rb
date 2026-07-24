class ModerationService
  def initialize(community)
    @client = OpenAI::Client.new
    @client.extra_headers["Helicone-Property-Model"] = "NewPostSummarizationService"
    @client.extra_headers["Helicone-Property-Environment"] = Rails.env
    @client.extra_headers["Helicone-Property-Community-Slug"] = community.slug
    @client.extra_headers["Helicone-User-Id"] = community.id.to_s

    @community = community
  end

  def call(model)
    text = "#{model.title}\n #{model.body.to_plain_text}" if model.is_a?(Post)
    text = model.body.to_plain_text if model.is_a?(Reply)
    text = "#{model.name}\n: #{model.about.to_plain_text}" if model.is_a?(Member)

    return test_response if Rails.env.test?

    res = @client.moderations(parameters: { model: "text-moderation-latest", input: text })
    Rails.logger.info "ModerationService for community #{@community.id}: #{text} => #{res}"
    res.dig("results", 0)
  end

  private

  def test_response
    { "flagged" => false,
     "categories" =>
     { "sexual" => false,
      "hate" => false,
      "harassment" => false,
      "self-harm" => false,
      "sexual/minors" => false,
      "hate/threatening" => false,
      "violence/graphic" => false,
      "self-harm/intent" => false,
      "self-harm/instructions" => false,
      "harassment/threatening" => false,
      "violence" => false },
     "category_scores" =>
     { "sexual" => 3.1753337680129334e-05,
      "hate" => 3.491978304737131e-06,
      "harassment" => 3.5892783216695534e-06,
      "self-harm" => 1.2886644071841147e-06,
      "sexual/minors" => 1.1100224810434156e-06,
      "hate/threatening" => 3.962186134742751e-09,
      "violence/graphic" => 3.3738541560524027e-07,
      "self-harm/intent" => 2.0048726412369433e-07,
      "self-harm/instructions" => 3.7251406403981946e-09,
      "harassment/threatening" => 8.418052033221102e-08,
      "violence" => 2.1685234969481826e-05 } }
  end
end
