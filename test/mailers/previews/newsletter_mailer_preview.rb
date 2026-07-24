class NewsletterMailerPreview < ActionMailer::Preview
  def new_newsletter
    community = Community.find_by_slug("hq")
    to_member = community.members.sample
    # Order by successful newsletters
    # Make new newsletter if it's been 24 hours since last one
    last_newsletter = to_member.newsletters.where(state: :success).order(created_at: :desc).first
    NewsletterMailer.new_newsletter(last_newsletter)
  end
end
