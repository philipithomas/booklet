namespace :disposable_email do
  desc "Downloads the latest list of disposable emails"
  task download: :environment do
    response = HTTParty.get("https://disposable.github.io/disposable-email-domains/domains.txt")
    data = response.body
    path = Rails.root.join("config/data/disposable_email_domains.txt")
    File.write(path, data)
    puts "Disposable email domains downloaded to #{path}"
  end
end
