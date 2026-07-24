class NewRepliesSummarizationService
  def initialize(newsletter, post, now: Time.now.in_time_zone("Eastern Time (US & Canada)"))
    @client = OpenAI::Client.new
    @client.extra_headers["Helicone-Property-Model"] = "NewRepliesSummarizationService"
    @client.extra_headers["Helicone-Property-Environment"] = Rails.env
    @client.extra_headers["Helicone-Property-Community-Slug"] = newsletter.community.slug
    @client.extra_headers["Helicone-User-Id"] = newsletter.community_id.to_s

    @newsletter = newsletter
    @previous_newsletter = newsletter.previous_newsletter
    @post = post
    @now = now
  end

  def call
    return "Mocked summary of #{post.id} new replies" if Rails.env.test?

    available_tokens = 8000 - OpenAI.rough_token_count(system_message)

    omit_reply_count = 0
    while OpenAI.rough_token_count(user_message(omit_reply_count)) > available_tokens
      Rails.logger.info("Omitting #{omit_reply_count} replies from newsletter #{newsletter.id} summary of replies to post #{post.id}")
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
    "Your job is summarize new Replies to an existing discussion on a Post. " \
    "This summary will be presented with the title of the post, so you can assume the reader has seen the title. " \
    "Your job is to describe what people are discussing since the last update, but you do not know if the readers are familiar with the original post or prior replies. " \
    "Summaries should use the first name of the author of the reply, and describe their reply in active voice in the third person. " \
    "You should concentrate the summary on new replies, but you can use context from the original post and old replies in your summary. " \
    "Your summary should be brief, and one to two sentences. " \
    "Just summarize the reply, don't call it a reply. " \
    "The style should be brief and friendly - but formal enough for a business context. Never use exclamation points. " \
    "Use simple sentence structures that are easy for people to understand. Refer to authors by their first name, as long as nobody else in the discussion shares their first name. " \
    "Use gender-neutral pronouns they/them when referring to people. " \
    "Do not ascribe emotion to a writer unless they state it explicitly. " \
    "Your summary does not have to be comprehensive. " \
    "Replies should be in plaintext, and not include any urls or formatting. " \
    "Replies are ordered from first to last. " \
    "If there are too many replies to summarize in one or two sentences, summarize the most recent replies. " \
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
        published_at: reply.created_at.in_time_zone("Eastern Time (US & Canada)").strftime("%A, %B %d, %Y"),
        # TODO - if user has replied after reply, they've seen it.
        new: @previous_newsletter.present? ? (reply.created_at > @previous_newsletter.created_at) : true
      }
    end
    # omit the first n replies
    response[omit_reply_count..]
  end
end
