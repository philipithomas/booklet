class GenerateNewsletterJob < ApplicationJob
  queue_as :default

  def perform(*communities)
    communities.each do |community|
      Newsletter.new(community: community).save!
    end
  end
end
