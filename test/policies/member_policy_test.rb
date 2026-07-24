require "test_helper"

class MemberPolicyTest < ApplicationPolicyTest
  test "new policy should only permit managers and admins" do
    permit @admin, Member, :new
    permit @manager, Member, :new
    refute_permit @member, Member, :new
    refute_permit @anonymous, Member, :new
  end

  test "create policy should only permit managers and admins" do
    permit @admin, Member, :create
    permit @manager, Member, :create
    refute_permit @member, Member, :create
    refute_permit @anonymous, Member, :create
  end

  test "index policy should only permit logged-in members" do
    permit @admin, @community, :index
    permit @manager, @community, :index
    permit @member, @community, :index
    permit @other_member, @community, :index
    refute_permit @anonymous, @community, :index
  end

  test "show policy for members" do
    permit @admin, @member, :show
    permit @manager, @member, :show
    permit @member, @member, :show
    permit @other_member, @member, :show
    refute_permit @anonymous, @member, :show
  end

  test "show policy for managers" do
    permit @admin, @manager, :show
    permit @manager, @manager, :show
    permit @member, @manager, :show
    permit @other_member, @manager, :show
    refute_permit @anonymous, @manager, :show
  end

  test "show policy for admins" do
    permit @admin, @admin, :show
    permit @manager, @admin, :show
    permit @member, @admin, :show
    permit @other_member, @admin, :show
    refute_permit @anonymous, @admin, :show
  end

  test "show policy for invited members" do
    permit @admin, @invited_member, :show
    permit @manager, @invited_member, :show
    refute_permit @member, @invited_member, :show
    refute_permit @other_member, @invited_member, :show
    refute_permit @anonymous, @invited_member, :show
  end

  test "show policy for unactivated members" do
    permit @admin, @unactivated_member, :show
    permit @manager, @unactivated_member, :show
    refute_permit @member, @unactivated_member, :show
    refute_permit @other_member, @unactivated_member, :show
    refute_permit @anonymous, @unactivated_member, :show
  end

  test "show policy for locked members" do
    permit @admin, @locked_member, :show
    permit @manager, @locked_member, :show
    permit @member, @locked_member, :show
    permit @other_member, @locked_member, :show
    refute_permit @anonymous, @locked_member, :show
  end

  [ :edit, :update ].each do |method|
    test "#{method} policy for members" do
      permit @admin, @member, method
      permit @manager, @member, method
      permit @member, @member, method
      refute_permit @other_member, @member, method
      refute_permit @anonymous, @member, method
    end

    test "#{method} policy for managers" do
      permit @admin, @manager, method
      permit @manager, @manager, method
      refute_permit @member, @manager, method
      refute_permit @other_member, @manager, method
      refute_permit @anonymous, @manager, method
    end

    test "#{method} policy for admins" do
      permit @admin, @admin, method
      refute_permit @manager, @admin, method
      refute_permit @member, @admin, method
      refute_permit @other_member, @admin, method
      refute_permit @anonymous, @admin, method
    end

    test "#{method} policy for invited members" do
      permit @admin, @invited_member, method
      permit @manager, @invited_member, method
      refute_permit @member, @invited_member, method
      refute_permit @other_member, @invited_member, method
      refute_permit @anonymous, @invited_member, method
    end

    test "#{method} policy for unactivated members" do
      permit @admin, @unactivated_member, method
      permit @manager, @unactivated_member, method
      refute_permit @member, @unactivated_member, method
      refute_permit @other_member, @unactivated_member, method
      refute_permit @anonymous, @unactivated_member, method
    end

    test "#{method} policy for locked members" do
      permit @admin, @locked_member, method
      permit @manager, @locked_member, method
      refute_permit @member, @locked_member, method
      refute_permit @other_member, @locked_member, method
      refute_permit @anonymous, @invited_member, method
    end
  end

  test "destroy policy for members" do
    permit @admin, @member, :destroy
    permit @manager, @member, :destroy
    refute_permit @member, @member, :destroy
    refute_permit @other_member, @member, :destroy
    refute_permit @anonymous, @member, :destroy
  end

  test "destroy policy for admins" do
    refute_permit @admin, @admin, :destroy
    refute_permit @manager, @admin, :destroy
    refute_permit @member, @admin, :destroy
    refute_permit @other_member, @admin, :destroy
    refute_permit @anonymous, @admin, :destroy
  end

  test "destroy policy for invited members" do
    permit @admin, @invited_member, :destroy
    permit @manager, @invited_member, :destroy
    refute_permit @member, @invited_member, :destroy
    refute_permit @other_member, @invited_member, :destroy
    refute_permit @anonymous, @invited_member, :destroy
  end

  test "destroy policy for unactivated members" do
    permit @admin, @unactivated_member, :destroy
    permit @manager, @unactivated_member, :destroy
    refute_permit @member, @unactivated_member, :destroy
    refute_permit @other_member, @unactivated_member, :destroy
    refute_permit @anonymous, @unactivated_member, :destroy
  end

  test "destroy policy for locked members" do
    permit @admin, @locked_member, :destroy
    permit @manager, @locked_member, :destroy
    refute_permit @member, @locked_member, :destroy
    refute_permit @other_member, @locked_member, :destroy
    refute_permit @anonymous, @locked_member, :destroy
  end
end
