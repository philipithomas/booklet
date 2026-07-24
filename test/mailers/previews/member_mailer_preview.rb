class MemberMailerPreview < ActionMailer::Preview
  def passwordless_signin_email
    member = Community.find_by_slug("hq").members.first # or however you want to fetch this
    MemberMailer.passwordless_signin_email(member)
  end
end
