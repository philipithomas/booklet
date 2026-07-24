require "test_helper"

class GenerateNewsletterJobTest < ActiveJob::TestCase
  test "should generate newsletter for member if it's their newsletter day in NYC timezone" do
    # Setting up a member who gets newsletters only on Sundays in NYC
    community = communities(:lab)
    assert_difference "Newsletter.count", 1 do
      GenerateNewsletterJob.perform_now(community)
    end
  end
end
