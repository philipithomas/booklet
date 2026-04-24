class EnqueueUKNewslettersJob < ApplicationJob
  queue_as :default

  def perform(*_)
    community = Community.find(217)
    if community.slug != "autrix"
      return
    end

    today_in_nyc = Time.current.in_time_zone("Eastern Time (US & Canada)").strftime("%A")
    if community.newsletter_on?(today_in_nyc)
      GenerateNewsletterJob.perform_later(community)
    else
      Rails.logger.info "Skipping uk newsletter generation for community #{community.id} - #{community.slug} - #{community.name} - #{today_in_nyc}"
    end
  end
end
