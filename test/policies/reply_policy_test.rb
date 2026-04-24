require "test_helper"

class ReplyPolicyTest < ApplicationPolicyTest
  test "index policy for replies" do
    post = @reply.post

    permit @admin, post, :index
    permit @manager, post, :index
    permit @member, post, :index
    permit @other_member, post, :index

    post.community.update!(visibility: :private)
    refute_permit @anonymous, post, :index

    post.community.update!(visibility: :unlisted)
    permit @anonymous, post, :index

    post.community.update!(visibility: :public)
    permit @anonymous, post, :index
  end

  test "show policy for replies" do
    post = @reply.post

    permit @admin, @reply, :show
    permit @manager, @reply, :show
    permit @member, @reply, :show
    permit @other_member, @reply, :show

    post.community.update!(visibility: :private)
    refute_permit @anonymous, @reply, :show

    post.community.update!(visibility: :unlisted)
    permit @anonymous, @reply, :show

    post.community.update!(visibility: :public)
    permit @anonymous, @reply, :show
  end

  test "create policy" do
    post = @reply.post

    permit @admin, post, :create
    permit @manager, post, :create
    permit @member, post, :create
    refute_permit @anonymous, post, :create
  end

  test "edit policy" do
    permit @member, @reply, :edit
    refute_permit @other_member, @reply, :edit
    refute_permit @admin, @reply, :edit
    refute_permit @manager, @reply, :edit
    refute_permit @anonymous, @reply, :edit
  end

  test "update policy" do
    permit @member, @reply, :update
    refute_permit @other_member, @reply, :update
    refute_permit @admin, @reply, :update
    refute_permit @manager, @reply, :update
    refute_permit @anonymous, @reply, :update
  end

  test "destroy policy for replies" do
    permit @admin, @reply, :destroy
    permit @manager, @reply, :destroy
    permit @member, @reply, :destroy
    refute_permit @other_member, @reply, :destroy
    refute_permit @anonymous, @reply, :destroy
  end
end
