ENV["RAILS_ENV"] ||= "test"
ENV["APP_MODE"] ||= "MULTIUSER"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def assert_permit(member, record, action)
    msg = "Member #{member.inspect} should be permitted to #{action} #{record.inspect}, but isn't permitted"
    assert permit(member, record, action), msg
  end

  def refute_permit(member, record, action)
    msg = "Member #{member.inspect} should NOT be permitted to #{action} #{record.inspect}, but is permitted"
    assert_not permit(member, record, action), msg
  end

  def permit(member, record, action)
    test_name = self.class.ancestors.find { |a| a.to_s.match(/PolicyTest/) }
    klass = test_name.to_s.gsub("Test", "")
    klass.constantize.new(member, record).public_send(:"#{action}?")
  end
end
