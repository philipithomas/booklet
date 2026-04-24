module Member::Addable
  extend ActiveSupport::Concern

  def direct_added!(activated: false)
    self.source = :direct_add
    self.subscribed_at = Time.now
    if activated
      self.confirmed_at = Time.now
    else
      skip_confirmation_notification!
    end
  end
end
