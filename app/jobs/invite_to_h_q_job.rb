# frozen_string_literal: true

class InviteToHQJob < ApplicationJob
  queue_as :low

  def perform(*members)
    return if Rails.configuration.solo_mode
    hq = Community.find_by_slug("hq")
    return unless hq
    members.each do |member|
      newbie = hq.members.new({ email: member.email, subscribed_at: Time.zone.now, send_welcome: false })
      newbie.invited_by = hq.members.where(permission: :admin).first
      newbie.direct_added!(activated: false)
      newbie.save!(validate: false)
    end
  end
end
