require "test_helper"

class PostPolicyTest < ApplicationPolicyTest
  test "index policy" do
    permit @admin, @community, :index
    permit @manager, @community, :index
    permit @member, @community, :index
    permit @other_member, @community, :index

    @community.update!(visibility: :private)
    refute_permit @anonymous, @community, :index

    @community.update!(visibility: :unlisted)
    permit @anonymous, @community, :index

    @community.update!(visibility: :public)
    permit @anonymous, @community, :index
  end

  test "show policy" do
    permit @admin, @post, :show
    permit @manager, @post, :show
    permit @member, @post, :show
    permit @member, @post, :show

    @community.update!(visibility: :private)
    refute_permit @anonymous, @post, :show

    @community.update!(visibility: :unlisted)
    permit @anonymous, @post, :show

    @community.update!(visibility: :public)
    permit @anonymous, @post, :show
  end

  [ :edit, :update ].each do |method|
    test "#{method} policy" do
      permit @admin, @post, method
      permit @manager, @post, method
      permit @member, @post, method
      refute_permit @other_member, @post, method
      refute_permit @anonymous, @post, method
    end
  end

  test "destroy policy for posts" do
    permit @admin, @post, :destroy
    permit @manager, @post, :destroy
    permit @member, @post, :destroy
    refute_permit @other_member, @post, :destroy
    refute_permit @anonymous, @post, :destroy
  end
end
