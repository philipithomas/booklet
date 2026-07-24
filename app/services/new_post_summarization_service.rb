class NewPostSummarizationService
  def initialize(newsletter, post, now: Time.now.in_time_zone("Eastern Time (US & Canada)"))
    @client = OpenAI::Client.new
    @client.extra_headers["Helicone-Property-Model"] = "NewPostSummarizationService"
    @client.extra_headers["Helicone-Property-Environment"] = Rails.env
    @client.extra_headers["Helicone-Property-Community-Slug"] = newsletter.community.slug
    @client.extra_headers["Helicone-User-Id"] = newsletter.community_id.to_s

    @newsletter = newsletter
    @previous_newsletter = newsletter.previous_newsletter
    @post = post
    @now = now
  end

  def call
    return "Mocked summary of post #{post.id}" if Rails.env.test?

    available_tokens = 8000 - OpenAI.rough_token_count(system_message)

    omit_reply_count = 0
    while OpenAI.rough_token_count(user_message(omit_reply_count)) > available_tokens
      Rails.logger.info("Omitting #{omit_reply_count} replies from newsletter #{newsletter.id} summary of post #{post.id}")
      omit_reply_count += 1
    end

    res = @client.chat(
      parameters: {
        model: "gpt-5.1",
        messages: [
          { role: "system", content: system_message },
          { role: "user", content: user_message(omit_reply_count) }
        ],
        user: @newsletter.community_id.to_s
      }
    )

    # Log response
    Rails.logger.info res
    raise "no response" if res.nil?
    summary = res.dig("choices", 0, "message", "content")
    raise "No summary" unless summary&.present?
    Rails.logger.debug summary
    summary.delete("\n")
  end

  private

  def system_message
    "You are a reporter covering an intellectual discussion. " \
    "Your job is summarize a Post and any replies to it. " \
    "This summary will be presented with the title of the post, so you can assume the reader has seen the title. " \
    "Your job is to summarize what people are discussing in the post and replies. " \
    "Summaries should use the first name of the author of the post or reply, and describe their reply in active voice in the third person. " \
    "Your summary should be brief, and one to two sentences. " \
    "Just summarize the post and replies, don't call it a post or reply. " \
    "The style should be brief and friendly - but formal enough for a business context. Never use exclamation points. " \
    "Refer to authors by their first name, as long as nobody else in the discussion shares their first name. " \
    "Use gender-neutral pronouns they/them when referring to people. " \
    "Use simple sentence structures that are easy for people to understand. " \
    "Do not ascribe emotion to a writer unless they state it explicitly. " \
    "Your summary does not have to be comprehensive. " \
    "The summary should be in plaintext, and not include any urls or formatting. " \
    "Replies are ordered from first to last, if there are any. " \
    "It's more important to summarize the post than the replies - if there are too many replies, just mention who replied or how many people replied. " \
    "If nobody has replied, then do not mention replies at all. " \
    "Today is #{@now.strftime("%A, %B %d, %Y")}."
  end

  def user_message(omit_reply_count = 0)
    payload = {
      post: {
        title: @post.title,
        author: @post.member.name,
        body: @post.body.to_plain_text,
        published_at: @post.published_at.in_time_zone("Eastern Time (US & Canada)").strftime("%A, %B %d, %Y")
      },
      replies: reply_data(omit_reply_count)
    }

    # return pretty-printed json
    JSON.pretty_generate(payload)
  end

  def reply_data(omit_reply_count = 0)
    response = []
    @post.replies.where(quarantined_at: nil).order(:created_at).map do |reply|
      response << {
        author: reply.member.name,
        body: reply.body.to_plain_text,
        published_at: reply.created_at.in_time_zone("Eastern Time (US & Canada)").strftime("%A, %B %d, %Y")
      }
    end
    # omit the last n replies
    response[0..-omit_reply_count]
  end
end
