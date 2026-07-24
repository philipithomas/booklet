# == Schema Information
#
# Table name: api_keys
#
#  id           :bigint           not null, primary key
#  deleted_at   :datetime
#  key_hash     :string           not null
#  last_used_at :datetime
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#
# Indexes
#
#  index_api_keys_on_community_id  (community_id)
#  index_api_keys_on_deleted_at    (deleted_at)
#  index_api_keys_on_key_hash      (key_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
require "test_helper"

class APIKeyTest < ActiveSupport::TestCase
  setup do
    @community = communities(:lab)
  end

  test "should create valid api key" do
    api_key = APIKey.new(name: "Test Key", community: @community)
    assert api_key.valid?
  end

  test "should not create api key without name" do
    api_key = APIKey.new(community: @community)
    assert_not api_key.valid?
  end

  test "should find api key by external key" do
    api_key = APIKey.create(name: "Test Key", community: @community)
    external_key = api_key.external_key
    found_key = APIKey.find_by_external_key(external_key)
    assert_equal api_key, found_key
  end

  test "should not find api key by invalid hash" do
    api_key = APIKey.create(name: "Test Key", community: @community)
    external_key = api_key.external_key
    invalid_key = external_key.gsub(/./, "0")
    found_key = APIKey.find_by_external_key(invalid_key)
    assert_nil found_key
  end

  test "Should not find api key with invalid id in key" do
    api_key = APIKey.create(name: "Test Key", community: @community)
    external_key = api_key.external_key
    invalid_id_key = external_key.gsub(/\d/, "0")
    found_key = APIKey.find_by_external_key(invalid_id_key)
    assert_nil found_key
  end

  test "should update last_used_at when key is looked up" do
    api_key = APIKey.create(name: "Test Key", community: @community)
    external_key = api_key.external_key
    assert_nil api_key.last_used_at
    found_key = APIKey.find_by_external_key(external_key)
    assert_not_nil found_key.last_used_at

    old_last_used_at = found_key.last_used_at
    found_key = APIKey.find_by_external_key(external_key)
    assert_not_equal old_last_used_at, found_key.last_used_at
  end

  test "should soft destroy api key" do
    api_key = APIKey.create(name: "Test Key", community: @community)
    assert_not_nil api_key
    assert_nil api_key.deleted_at
    api_key.soft_destroy
    assert_not_nil api_key.deleted_at
  end

  test "should not include soft deleted api key in default scope" do
    api_key = APIKey.create(name: "Test Key", community: @community)
    assert_not_nil api_key
    assert_nil api_key.deleted_at
    assert_includes APIKey.all, api_key
    api_key.soft_destroy
    assert_not_includes APIKey.all, api_key
  end
end
