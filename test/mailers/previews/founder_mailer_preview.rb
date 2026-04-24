class FounderMailerPreview < ActionMailer::Preview
  def welcome
    member = Member.where(permission: :admin).last
    FounderMailer.welcome(member)
  end
end
