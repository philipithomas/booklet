# == Schema Information
#
# Table name: domains
#
#  id                :bigint           not null, primary key
#  apex              :boolean          default(FALSE)
#  domain            :string           not null
#  redirect_for_name :string
#  verified          :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  community_id      :bigint           not null
#
# Indexes
#
#  index_domains_on_community_id  (community_id)
#  index_domains_on_domain        (domain) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
require "test_helper"

class DomainTest < ActiveSupport::TestCase
  def setup
    @community = communities(:lab)
  end

  test "should not save domain without community" do
    domain = Domain.new
    assert_not domain.save
  end

  test "should not save domain without domain" do
    domain = Domain.new
    domain.community = communities(:lab)
    assert_not domain.save
  end

  test "should not save domain with invalid domain" do
    domain = Domain.new
    domain.community = communities(:lab)
    domain.domain = "invalid"
    assert_not domain.save
  end

  test "should not save domain with duplicate domain" do
    Domain.create!(community: Community.create(name: "Foo", slug: "foo", email: "foo@foo.com"), domain: "lab.fbi.com")

    domain = Domain.new
    domain.community = communities(:lab)
    domain.domain = "lab.fbi.com"
    assert_not domain.save
  end

  test "should save domain with valid domain" do
    domain = Domain.new
    domain.community = communities(:lab)
    domain.domain = "new.localtest.me"
    assert domain.save
  end

  test "should not save domain with duplicate domain case insensitive" do
    Domain.create!(community: Community.create(name: "Foo", slug: "foo", email: "hey@hey.com"), domain: "lab.fbi.com")

    domain = Domain.new
    domain.community = communities(:lab)
    domain.domain = "lab.fbi.com"
    assert_not domain.save
  end
end
