# frozen_string_literal: true

class VisitsInLastDayJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # Collect members who have triggered an Ahoy event in the last 24 hours,
    # aggregated per community so no member PII leaves the application
    member_ids = Ahoy::Event.where("time > ?", 1.day.ago).pluck(:user_id).uniq
    members = Member.includes(:community).where(id: member_ids)

    lines = [
      "#{members.count} people used Booklet in the last day:"
    ]

    counts = members.group_by { |member| member.community&.slug || "unknown" }
    counts.sort_by { |_slug, community_members| -community_members.size }.each do |slug, community_members|
      lines << "- #{slug}: #{community_members.size}"
    end

    message = lines.join("\n")

    # Post the message to the configured admin chat
    PostInAdminChatJob.perform_now(message)
  end
end
