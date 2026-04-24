def random_profile_picture
  image_files = Dir.glob("app/assets/images/sample-profile-photos/*")
  image_files.sample
end

def create_member!(**kwargs)
  member = Member.create!(
    community: kwargs.fetch(:community, nil),
    name: kwargs.fetch(:name) { Faker::Name.name },
    permission: kwargs.fetch(:permission, :member),
    email: kwargs.fetch(:email) { "#{Faker::Alphanumeric.unique.alphanumeric(number: 10)}@example.com" },
    password: "password",
    confirmed_at: kwargs.fetch(:confirmed_at, Time.now),
    source: :public_join
  )

  member.photo.attach(io: File.open(random_profile_picture), filename: "p.png") if rand(0..1) == 1
  member.about = Faker::Lorem.paragraphs(number: rand(1..3)).join("\n\n") if rand(0..1) == 1
  member.save!
end

if Rails.configuration.solo_mode
  # Solo mode: single community with one admin
  puts "Creating community (solo mode)"
  community = Community.create!(
    name: "My Community",
    slug: "community",
    visibility: :public,
    email: "admin@example.com",
    brand_color: "#4D3DF7"
  )
  community.set_payment_processor :fake_processor, allow_fake: true
  community.payment_processor.subscribe(plan: "fake")

  puts "Creating admin member"
  admin = Member.create!(
    community: community,
    name: "Admin",
    permission: :admin,
    email: "admin@example.com",
    password: "password",
    confirmed_at: Time.now,
    source: :creator
  )

  puts "Creating sample members"
  10.times { create_member!(community: community) }

  puts "Creating sample posts"
  community.members.active.each do |member|
    rand(0..2).times do
      post = Post.create!(
        community: community,
        member: member,
        title: Faker::Lorem.sentence,
        body: Faker::Lorem.paragraphs(number: rand(1..5)).join("\n\n"),
        published_at: rand(1..90).days.ago
      )
      rand(0..5).times do
        post.replies.create!(
          member: community.members.active.sample,
          body: Faker::Lorem.paragraphs(number: rand(1..3)).join("\n\n"),
          created_at: rand(post.published_at..Time.now)
        )
      end
      rand(0..community.members.active.count).times do
        post.views.create!(member: community.members.active.sample)
      end
    end
  end

else
  # Multiuser mode: multiple communities for development/testing
  puts "Creating Editor"
  Editor.create!(
    email: "admin@example.com",
    password: "password"
  )

  puts "Creating HQ"
  hq = Community.create!(name: "Booklet HQ", slug: "hq", visibility: :public, email: "hq@example.com", created_at: 1.year.ago, brand_color: "#4D3DF7")
  hq.set_payment_processor :fake_processor, allow_fake: true
  hq.payment_processor.subscribe(plan: "fake")
  hq.icon.attach(io: File.open("app/assets/images/logo/hq/icon.png"), filename: "hq_icon.png")
  hq.logo.attach(io: File.open("app/assets/images/logo/hq/wordmark.svg"), filename: "hq-wordmark-accent.svg")
  hq.logo_for_dark_background.attach(io: File.open("app/assets/images/logo/hq/wordmark_inverted.svg"), filename: "hq-wordmark.svg")

  puts "Creating HQ members"
  100.times { create_member!(community: hq) }
  10.times { create_member!(community: hq, confirmed_at: nil) }
  5.times { hq.members.invite!(email: Faker::Internet.email, source: "invited") }

  create_member!(community: hq, permission: :manager)
  create_member!(community: hq, permission: :admin)

  admin = Member.create!(
    community: hq,
    name: "Admin User",
    permission: :admin,
    email: "admin@example.com",
    password: "password",
    confirmed_at: Time.now,
    source: :creator
  )
  admin.photo.attach(io: File.open("app/assets/images/philip.jpg"), filename: "philip.jpg")
  admin.about = "Community administrator."
  admin.save!

  puts "Creating HQ posts"
  hq.members.active.each do |member|
    rand(0..2).times do
      post = Post.create!(
        community: hq,
        member: member,
        title: Faker::Lorem.sentence,
        body: Faker::Lorem.paragraphs(number: rand(1..10)).join("\n\n"),
        published_at: rand(1..365).days.ago
      )
      rand(0..20).times do
        post.replies.create!(
          member: hq.members.active.sample,
          body: Faker::Lorem.paragraphs(number: rand(1..3)).join("\n\n"),
          created_at: rand(post.published_at..Time.now)
        )
      end
      rand(0..hq.members.active.count).times do
        post.views.create!(member: hq.members.active.sample)
      end
    end
  end

  puts "Creating DSV"
  dsv = Community.create!(name: "Dimes Square Ventures", slug: "dsv", visibility: :private, email: "dsv@example.com", brand_color: "#099AA4")
  dsv.set_payment_processor :fake_processor, allow_fake: true
  dsv.payment_processor.subscribe(plan: "fake")
  dsv.icon.attach(io: File.open("app/assets/images/dsv/icon.png"), filename: "icon.png")
  dsv.logo.attach(io: File.open("app/assets/images/dsv/wordmark.png"), filename: "wordmark.png")

  puts "Creating DSV members"
  5.times { create_member!(community: dsv) }

  member = Member.create!(
    community: dsv,
    name: "Admin User",
    permission: :member,
    email: "dsv-member@example.com",
    password: "password",
    confirmed_at: Time.now,
    source: :public_join
  )
  member.photo.attach(io: File.open("app/assets/images/philip.jpg"), filename: "philip.jpg")
  member.about = "Community member."
  member.save!

  puts "Creating DSV posts"
  dsv.members.active.each do |member|
    rand(0..5).times do
      post = Post.create!(
        community: dsv,
        member: member,
        title: Faker::Lorem.sentence,
        body: Faker::Lorem.paragraphs(number: rand(1..3)).join("\n\n"),
        published_at: rand(1..365).days.ago
      )
      rand(0..3).times do
        post.replies.create!(
          member: dsv.members.active.sample,
          body: Faker::Lorem.paragraphs(number: rand(1..3)).join("\n\n"),
          created_at: rand(post.published_at..Time.now)
        )
      end
      rand(0..dsv.members.active.count).times do
        post.views.create!(member: dsv.members.active.sample)
      end
    end
  end
end
