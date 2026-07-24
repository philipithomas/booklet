# == Schema Information
#
# Table name: verifications
#
#  id                       :bigint           not null, primary key
#  document_address         :jsonb
#  document_dob             :jsonb
#  document_expiration_date :jsonb
#  document_first_name      :string
#  document_issued_date     :jsonb
#  document_issuing_country :string
#  document_last_name       :string
#  document_number          :string
#  document_type            :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  person_id                :bigint           not null
#  stripe_verification_id   :string
#
# Indexes
#
#  index_verifications_on_document_details          (document_issuing_country,document_number,document_type)
#  index_verifications_on_document_issuing_country  (document_issuing_country)
#  index_verifications_on_document_number           (document_number)
#  index_verifications_on_document_type             (document_type)
#  index_verifications_on_person_id                 (person_id)
#  index_verifications_on_stripe_verification_id    (stripe_verification_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#
require "test_helper"

class VerificationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
