# Preview all emails at http://localhost:3000/rails/mailers/community_devise_mailer
class CommunityDeviseMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    CustomDeviseMailer.confirmation_instructions(Member.first, "faketoken")
  end

  def reset_password_instructions
    CustomDeviseMailer.reset_password_instructions(Member.first, "faketoken")
  end

  def invitation_instructions
    CustomDeviseMailer.invitation_instructions(Member.first, "faketoken")
  end
end
