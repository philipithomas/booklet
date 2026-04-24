class DraftRecommendationService
  def initialize(member)
    @client = OpenAI::Client.new

    @recommendation_count = 6
    @member = member
    @community = member.community
    @member_posts = member.posts.published.limit(3)
    @community_posts = member.community.posts.published.where.not(member_id: member.id).order(published_at: :desc).limit(5)
  end

  def call
    res = @client.chat(
      parameters: {
        model: "gpt-5-nano",
        messages: [
          { role: "system", content: system_message },
          { role: "user", content: user_message }
        ],
        user: @member.community_id.to_s,
        response_format: { type: "json_object" }
      }
    )

    # Log response
    Rails.logger.info res
    raise "no response" if res.nil?
    output = res.dig("choices", 0, "message", "content")
    Rails.logger.debug output
    recommendations_json = JSON.parse(output)
    recommendations = recommendations_json["recommendations"]
    if recommendations.is_a?(Array) && recommendations.all? { |rec| rec.is_a?(String) }
      recommendations
    else
      raise "Invalid format for recommendations"
    end
  end

  private

  def system_message
    output = [
      "You are a community manager for #{@community.name}.",
      "Your job is to recommend new posts for #{@member.name} to write in the community.",
      "To do this, analyze the user's past posts, and any past posts in the community, and recommend new posts to write.",
      "Recommendations should be brief and just a few words.",
      "Some ways to generate a recommendation:",
      "- If you notice a trend of posts, such as weekly update, you can suggest the next logical update in that series.",
      "- If the community is a group of professionals who do not work together, you can suggest posts about 'Introducing myself', 'Seeking advice', 'Sharing an update'",
      "Examples of good suggestions:",
      "- What I'm working on",
      "- Sharing an article I just read",
      "- Seeking feedback on a topic",
      "When generating recommendations, do not lie - instead, be vague. For instance, it is ok to have a recommendation such as 'Sharing a new feature' because it is recommending the topic of the post without giving away the specifics of the post.",
      "Posts will be shared in JSON format, including any replies to the posts.",
      "Write recommendations in sentence case - only capitalize the first letter of the recommendation and proper nouns.",
      "Respond in JSON with a 'recommendations' key with an array of the recommendations, like this:",
      "{ recommendations: ['Recommendation 1', 'Recommendation 2', 'Recommendation 3'] }"
    ]

    if @member.about.present?
      output << "#{@member.name} has provided a short about section, so you can use this to generate a recommendation: #{@member.about.to_plain_text}"
    end
    output << "Return exactly #{@recommendation_count} recommendations!"
    output.join("\n")
  end

  def user_message(omit_reply_count = 0)
    output = []
    if @community.pinned_post.present?
      output << "# Pinned post"
      output << "A moderator has pinned this post, so analyze it and follow its instructions for appropriate posts. ALWAYS follow rules from this post when suggesting new posts."
      output << JSON.pretty_generate(post_data(@community.pinned_post))
    end

    if @member_posts.any?
      output << "# Member posts"
      output << "The following posts have been written by the member who you are recommending posts for:"
      @member_posts.map { |post|
        output << JSON.pretty_generate(post_data(post))
      }
    end

    if @community_posts.any?
      output << "# Community posts"
      output << "The following posts have been written by other members in the community:"
      @community_posts.map { |post|
        output << JSON.pretty_generate(post_data(post))
      }
    end

    output.join("\n")
  end

  def post_data(post)
    {
      title: post.title,
      author: post.member.name,
      body: post.body.to_plain_text.gsub("\n", " "),
      published_at: post.published_at.in_time_zone("Eastern Time (US & Canada)").strftime("%A, %B %d, %Y"),
      replies: post.replies.map do |reply|
        {
          author: reply.member.name,
          body: reply.body.to_plain_text.gsub("\n", " "),
          published_at: reply.created_at.in_time_zone("Eastern Time (US & Canada)").strftime("%A, %B %d, %Y")
        }
      end
    }
  end
end
