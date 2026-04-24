class NewsletterSubjectSummarizationService
  def initialize(newsletter, now: Time.now.in_time_zone("Eastern Time (US & Canada)"))
    @client = OpenAI::Client.new
    @client.extra_headers["Helicone-Property-Model"] = "NewsletterSubjectSummarizationService"
    @client.extra_headers["Helicone-Property-Environment"] = Rails.env
    @client.extra_headers["Helicone-Property-Community-Slug"] = newsletter.community.slug
    @client.extra_headers["Helicone-User-Id"] = newsletter.community_id.to_s

    @newsletter = newsletter
    @now = now
  end

  def call
    return "Mocked subject" if Rails.env.test?

    available_tokens = 8000 - OpenAI.rough_token_count(system_message)

    omit_count = 0
    while OpenAI.rough_token_count(user_message(omit_count)) > available_tokens
      Rails.logger.info("Omitting #{omit_count} replies from newsletter #{newsletter.id} summary of post #{post.id}")
      omit_count += 1
    end

    res = @client.chat(
      parameters: {
        model: "gpt-5.1",
        messages: [
          { role: "system", content: system_message },
          { role: "user", content: user_message(omit_count) }
        ],
        user: @newsletter.community_id.to_s
      }
    )

    # Log response
    Rails.logger.info res
    raise "no response" if res.nil?
    subject = res.dig("choices", 0, "message", "content")
    raise "No subject" unless subject&.present?
    Rails.logger.debug subject
    # Trim trailing and leading quotes
    subject.delete("\n").gsub(/\A['"]|['"]\z/, "")
  end

  private

  def system_message
    "Your job is to write a title for a newsletter that summarizes the topics of new posts and active discussions. " \
    "The title should just state the topics of the email. " \
    "The title does not need to be a complete sentence or have verbs. " \
    "The title should be brief and friendly - but formal enough for a business context. Never use excalamation points. " \
    "The title does not have to be comprehensive. " \
    "Do not ascribe emotion to a writer unless they state it explicitly. " \
    "The title should be in plaintext, and not include any urls or formatting. " \
    "Refer to authors by their first name, as long as nobody else in the discussion shares their first name. " \
    "Write in active voice in the third person. " \
    "It's more important that the title summarizes the post titles than the descriptions. " \
    "Today is #{@now.strftime("%A, %B %d, %Y")}."
  end

  def user_message(omit_count = 0)
    payload = {}
    new_posts_count = @newsletter.new_posts.count
    active_discussion_count = @newsletter.existing_post_with_new_replies.count

    discussion_limit = (active_discussion_count > omit_count) ? (active_discussion_count - omit_count) : 0
    new_post_limit = (omit_count > active_discussion_count) ? (new_posts_count - (omit_count - active_discussion_count)) : new_posts_count

    payload["New posts"] = new_post_data(new_post_limit)
    payload["Active discussions"] = active_discussion_data(discussion_limit) if discussion_limit > 0

    # return pretty-printed json
    JSON.pretty_generate(payload)
  end

  def new_post_data(limit)
    data = []
    @newsletter.new_posts.limit(limit).map do |post|
      data << {
        title: post.title,
        post_author: post.member.name,
        description: @newsletter.new_post_summary(post)
      }
    end
    data
  end

  def active_discussion_data(limit)
    data = []
    @newsletter.existing_post_with_new_replies.limit(limit).map do |post|
      data << {
        title: post.title,
        description: @newsletter.new_replies_summary(post)
      }
    end
    data
  end
end
