module NewsletterDaysBitmask
  extend ActiveSupport::Concern

  DAYS = {
    "Sunday" => 1,
    "Monday" => 2,
    "Tuesday" => 4,
    "Wednesday" => 8,
    "Thursday" => 16,
    "Friday" => 32,
    "Saturday" => 64
  }.freeze

  def newsletter_days
    DAYS.select { |day, bitmask| (newsletter_days_bitmask & bitmask).nonzero? }.keys
  end

  def default_newsletter_days
    DAYS.select { |day, bitmask| (default_newsletter_days_bitmask & bitmask).nonzero? }.keys
  end

  def newsletter_on?(day)
    (newsletter_days_bitmask & DAYS[day]).nonzero?
  end

  def set_newsletter_day(day, value)
    if value
      self.newsletter_days_bitmask |= DAYS[day]
    else
      self.newsletter_days_bitmask &= ~DAYS[day]
    end
  end

  def newsletter_days_present?
    !newsletter_days_bitmask.nil?
  end
end
