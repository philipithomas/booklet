namespace :booklet do
  desc "First-run setup: create the initial community and admin member. " \
    "Configure with ADMIN_EMAIL (required), ADMIN_PASSWORD (generated if unset), " \
    "ADMIN_NAME, COMMUNITY_NAME, and COMMUNITY_SLUG."
  task bootstrap: :environment do
    abort("A community already exists — nothing to do.") if Community.any?

    email = ENV["ADMIN_EMAIL"].presence || abort("Set ADMIN_EMAIL to the administrator's email address.")
    password = ENV["ADMIN_PASSWORD"].presence || SecureRandom.base58(20)

    community = Community.create!(
      name: ENV.fetch("COMMUNITY_NAME", "My Community"),
      slug: ENV.fetch("COMMUNITY_SLUG", "my-community"),
      visibility: :public,
      email: email
    )
    community.set_payment_processor :fake_processor, allow_fake: true
    community.payment_processor.subscribe(plan: "fake")

    Member.create!(
      community: community,
      name: ENV.fetch("ADMIN_NAME", "Admin"),
      permission: :admin,
      email: email,
      password: password,
      confirmed_at: Time.current,
      source: :creator
    )

    puts "Created community #{community.name.inspect}"
    puts "Admin sign-in: #{email}"
    puts "Admin password: #{password}" if ENV["ADMIN_PASSWORD"].blank?
  end
end
