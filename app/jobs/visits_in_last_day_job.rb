# frozen_string_literal: true

class VisitsInLastDayJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # Collect members who have triggered an Ahoy event in the last 24 hours
    member_ids = Ahoy::Event.where("time > ?", 1.day.ago).pluck(:user_id).uniq
    members = Member.includes(:community).where(id: member_ids).order(:community_id, :name)

    # Build a multi-line message suitable for posting in the admin chat
    lines = [
      "#{members.count} people used Booklet in the last day:"
    ]

    member_lines = members.map do |member|
      community_part = member.community&.slug || "unknown"
      permission_part = member.member? ? "" : " [#{member.permission}]"
      "- #{community_part} – #{member.email}#{permission_part}"
    end

    lines.concat(member_lines)

    message = lines.join("\n")

    # Post the message to the configured admin chat
    PostInAdminChatJob.perform_now(message)
  end
end
