# Preview all emails at http://localhost:3000/rails/mailers/community_owner_mailer
class CommunityAdminMailerPreview < ActionMailer::Preview
  def domain_verified
    community = Community.first
    CommunityOwnerMailer.domain_verified(community)
  end
end
