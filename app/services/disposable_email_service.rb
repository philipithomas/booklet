module DisposableEmailService
  module_function

  def disposable?(email_address)
    email = begin
      Mail::Address.new(email_address.downcase)
    rescue
      nil
    end

    if email
      disposable_email_domains.include?(email.domain)
    else
      false
    end
  end

  def disposable_email_domains
    @_disposable_email_domains ||= File.readlines(Rails.root.join("config", "data", "disposable_email_domains.txt")).map(&:strip)
  end
end
