class VerifyDomainsJob < ApplicationJob
  def perform(*_args)
    return if Rails.configuration.solo_mode
    Domain.where(verified: false).order(Arel.sql("RANDOM()")).each do |domain|
      domain.update_verification_status
    end
  end
end
