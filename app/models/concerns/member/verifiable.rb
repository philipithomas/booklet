module Member::Verifiable
  extend ActiveSupport::Concern

  def identity_verified?
    person.present? && person.verifications.any?
  end

  def verification_url(return_url: nil)
    verification_session = Stripe::Identity::VerificationSession.create({
      type: "document",
      client_reference_id: id.to_s,
      options: {
        document: {
          require_id_number: false,
          require_live_capture: true,
          require_matching_selfie: true
        }
      },
      provided_details: {
        email: email
      },
      metadata: {
        member_id: id.to_s,
        community_id: community.id.to_s,
        member_email: email,
        community_host: community.host
      },
      return_url: return_url
    })
    verification_session.url
  end
end
