class StripeIdentityVerificationSessionVerifiedProcessor
  include PrefixedLogger

  def call(event)
    # Handle the event
    log_info "Processing event: #{event.id}"

    member_id = event.data.object.metadata.member_id
    member = Member.find_by(id: member_id)

    return log_error "Member not found for event: #{event.id}" if member.nil?

    verification = Verification.find_by(stripe_verification_id: event.data.object.id)
    return log_info "Verification already processed for event: #{event.id}" if verification

    verification_report = Stripe::Identity::VerificationReport.retrieve({ id: event.data.object.last_verification_report, expand: [ "document.dob", "document.expiration_date", "document.number" ] })

    # safety checks
    raise "Mismatched report" if verification_report.verification_session != event.data.object.id
    raise "document not verified" if verification_report.document.status != "verified"

    matching_verification = Verification.find_by(document_issuing_country: verification_report.document.issuing_country, document_number: verification_report.document.number, document_type: verification_report.document.type)

    if matching_verification
      log_info "Verification already exists for credentials in event: #{event.id} - new verification #{event.data.object.id} matches existing verification #{matching_verification.stripe_verification_id}"
      set_member_person(member, matching_verification.person)
      member.reload
    end

    # Create verification

    if member.person.nil?
      log_info "Creating person for member: #{member.id}"
      new_person = Person.create
      set_member_person(member, new_person)
      member.reload
    end

    verification = member.person.verifications.create(
      document_first_name: verification_report.document.first_name,
      document_last_name: verification_report.document.last_name,
      document_issuing_country: verification_report.document.issuing_country,
      document_number: verification_report.document.number,
      document_type: verification_report.document.type,
      document_address: verification_report.document.address,
      document_issued_date: verification_report.document.issued_date,
      document_expiration_date: verification_report.document.expiration_date,
      stripe_verification_id: event.data.object.id
    )

    notify_success(member)

    verification_report.document.files.each do |file_id|
      file = Stripe::File.retrieve(file_id)
      file_link = Stripe::FileLink.create({ file: file.id,
        expires_at: Time.now.to_i + 20 })
      verification.document_files.attach(io: URI.open(file_link.url), filename: file.filename)
    end

    selfie = Stripe::File.retrieve(verification_report.selfie.document)
    selfie_link = Stripe::FileLink.create({ file: selfie.id,
      expires_at: Time.now.to_i + 20 })
    verification.selfie.attach(io: URI.open(selfie_link.url), filename: selfie.filename)
    verification.save!


    log_info "Verification created: #{verification.id} for member: #{member.id} from event: #{event.id}"
  end

  private

  def set_member_person(member, person)
    # Update all members with that email to that person
    log_info "Setting person: #{person.id} for email: #{member.email}"
    Member.where(email: member.email).each do |m|
      log_info "Updating member: #{m.id} to person: #{person.id}"
      m.update(person: person)
    end
  end

  def notify_success(member)
    # Notify the member
    log_info "Notifying member: #{member.id}"
    MemberMailer.identity_verified(member).deliver_later
  end
end
