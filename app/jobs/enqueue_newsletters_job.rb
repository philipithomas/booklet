class EnqueueNewslettersJob < ApplicationJob
  queue_as :default

  def perform(*_)
    Community.find_each do |community|
      next if community.slug == "autrix" && community.id == 217

      today_in_nyc = Time.current.in_time_zone("Eastern Time (US & Canada)").strftime("%A")
      if community.newsletter_on?(today_in_nyc)
        GenerateNewsletterJob.perform_later(community)
      else
        Rails.logger.info "Skipping newsletter generation for community #{community.id} - #{community.slug} - #{community.name} - #{today_in_nyc}"
      end
    end
  end
end
