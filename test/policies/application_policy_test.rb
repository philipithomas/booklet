require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  setup do
    @community = communities(:lab)

    @admin = members(:admin)
    @manager = members(:manager)
    @member = members(:member)
    @other_member = members(:other_member)
    @invited_member = members(:invited_member)
    @unactivated_member = members(:unactivated_member)
    @locked_member = members(:locked_member)
    @anonymous = nil

    @post = posts(:post)
    @reply = replies(:reply_to_hello_world)
  end
end
