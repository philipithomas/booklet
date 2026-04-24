# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_04_01_051054) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "vector"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.bigint "community_id", null: false
    t.index ["community_id"], name: "index_activities_on_community_id"
    t.index ["member_id"], name: "index_activities_on_member_id"
    t.index ["target_type", "target_id"], name: "index_activities_on_target"
  end

  create_table "ahoy_clicks", force: :cascade do |t|
    t.string "campaign"
    t.string "token"
    t.index ["campaign"], name: "index_ahoy_clicks_on_campaign"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_messages", force: :cascade do |t|
    t.string "user_type"
    t.bigint "user_id"
    t.string "to"
    t.string "mailer"
    t.text "subject"
    t.datetime "sent_at"
    t.bigint "community_id"
    t.string "campaign"
    t.string "token"
    t.text "content"
    t.bigint "newsletter_id"
    t.index ["campaign"], name: "index_ahoy_messages_on_campaign"
    t.index ["community_id"], name: "index_ahoy_messages_on_community_id"
    t.index ["newsletter_id"], name: "index_ahoy_messages_on_newsletter_id"
    t.index ["to"], name: "index_ahoy_messages_on_to"
    t.index ["token"], name: "index_ahoy_messages_on_token", unique: true
    t.index ["user_type", "user_id"], name: "index_ahoy_messages_on_user"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "key_hash", null: false
    t.bigint "community_id", null: false
    t.string "name", null: false
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["community_id"], name: "index_api_keys_on_community_id"
    t.index ["deleted_at"], name: "index_api_keys_on_deleted_at"
    t.index ["key_hash"], name: "index_api_keys_on_key_hash", unique: true
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "audits1984_audits", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.bigint "session_id", null: false
    t.bigint "auditor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auditor_id"], name: "index_audits1984_audits_on_auditor_id"
    t.index ["session_id"], name: "index_audits1984_audits_on_session_id"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "communities", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.bigint "ahoy_create_visit_id"
    t.integer "visibility", default: 0, null: false
    t.integer "signups", default: 0, null: false
    t.string "brand_color", default: "#4D3DF7", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.boolean "open_ai_content_moderation_enabled", default: true, null: false
    t.boolean "open_ai_member_moderation_enabled", default: false, null: false
    t.integer "default_newsletter_days_bitmask", default: 127, null: false
    t.integer "newsletter_days_bitmask", default: 127, null: false
    t.string "vapid_public_key"
    t.string "vapid_private_key"
    t.bigint "pinned_post_id"
    t.boolean "directory_enabled", default: true, null: false
    t.string "email_visibility", default: "open", null: false
    t.index ["pinned_post_id"], name: "index_communities_on_pinned_post_id"
    t.index ["slug"], name: "index_communities_on_slug", unique: true
  end

  create_table "console1984_commands", force: :cascade do |t|
    t.text "statements"
    t.bigint "sensitive_access_id"
    t.bigint "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sensitive_access_id"], name: "index_console1984_commands_on_sensitive_access_id"
    t.index ["session_id", "created_at", "sensitive_access_id"], name: "on_session_and_sensitive_chronologically"
  end

  create_table "console1984_sensitive_accesses", force: :cascade do |t|
    t.text "justification"
    t.bigint "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_console1984_sensitive_accesses_on_session_id"
  end

  create_table "console1984_sessions", force: :cascade do |t|
    t.text "reason"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_console1984_sessions_on_created_at"
    t.index ["user_id", "created_at"], name: "index_console1984_sessions_on_user_id_and_created_at"
  end

  create_table "console1984_users", force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_console1984_users_on_username"
  end

  create_table "domains", force: :cascade do |t|
    t.string "domain", null: false
    t.boolean "verified", default: false
    t.bigint "community_id", null: false
    t.string "redirect_for_name"
    t.boolean "apex", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_domains_on_community_id"
    t.index ["domain"], name: "index_domains_on_domain", unique: true
  end

  create_table "editors", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.string "followable_type", null: false
    t.bigint "followable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followable_type", "followable_id"], name: "index_follows_on_followable"
    t.index ["member_id", "followable_type", "followable_id"], name: "index_follows_on_member_and_followable", unique: true
    t.index ["member_id"], name: "index_follows_on_member_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "index_pins", force: :cascade do |t|
    t.string "code", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_index_pins_on_email"
  end

  create_table "login_activities", force: :cascade do |t|
    t.string "scope"
    t.string "strategy"
    t.string "identity"
    t.boolean "success", default: false, null: false
    t.string "failure_reason"
    t.string "user_type"
    t.bigint "user_id"
    t.string "context"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "city"
    t.string "region"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at"
    t.bigint "community_id"
    t.string "host"
    t.index ["community_id"], name: "index_login_activities_on_community_id"
    t.index ["identity"], name: "index_login_activities_on_identity"
    t.index ["ip"], name: "index_login_activities_on_ip"
    t.index ["user_type", "user_id"], name: "index_login_activities_on_user"
  end

  create_table "members", force: :cascade do |t|
    t.bigint "community_id", null: false
    t.string "email"
    t.datetime "locked_at"
    t.string "name", default: "", null: false
    t.integer "permission", default: 0, null: false
    t.string "slug", default: "", null: false
    t.bigint "ahoy_join_visit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "newsletter_days_bitmask"
    t.datetime "quarantined_at"
    t.boolean "notify_new_posts_email", default: false, null: false
    t.boolean "notify_new_posts_push", default: false, null: false
    t.boolean "notify_mentions_email", default: true, null: false
    t.boolean "notify_mentions_push", default: true, null: false
    t.boolean "notify_newsletter_email", default: true, null: false
    t.boolean "notify_newsletter_push", default: true, null: false
    t.string "source"
    t.datetime "subscribed_at"
    t.integer "person_id"
    t.index "lower((name)::text)", name: "index_members_on_lowercase_name"
    t.index ["community_id", "slug"], name: "index_memberships_on_community_id_and_slug", unique: true
    t.index ["community_id"], name: "index_members_on_community_id"
    t.index ["confirmation_token"], name: "index_members_on_confirmation_token", unique: true
    t.index ["email", "community_id"], name: "email_unique_per_community", unique: true
    t.index ["invitation_token"], name: "index_members_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_members_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_members_on_invited_by"
    t.index ["locked_at"], name: "index_members_on_locked_at"
    t.index ["permission"], name: "index_members_on_permission"
    t.index ["quarantined_at"], name: "index_members_on_quarantined_at"
    t.index ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true
    t.index ["source"], name: "index_members_on_source"
    t.index ["subscribed_at"], name: "index_members_on_subscribed_at"
  end

  create_table "members_newsletters", id: false, force: :cascade do |t|
    t.bigint "newsletter_id", null: false
    t.bigint "member_id", null: false
    t.index ["member_id"], name: "index_members_newsletters_on_member_id"
    t.index ["newsletter_id"], name: "index_members_newsletters_on_newsletter_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.bigint "member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_mentions_on_member_id"
    t.index ["source_type", "source_id", "member_id"], name: "index_mentions_on_source_type_and_source_id_and_member_id", unique: true
    t.index ["source_type", "source_id"], name: "index_mentions_on_source"
  end

  create_table "moderation_scores", force: :cascade do |t|
    t.string "moderatable_type", null: false
    t.bigint "moderatable_id", null: false
    t.boolean "flagged", default: false, null: false
    t.jsonb "categories", default: {}
    t.jsonb "category_scores", default: {}
    t.datetime "content_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categories"], name: "index_moderation_scores_on_categories"
    t.index ["flagged"], name: "index_moderation_scores_on_flagged"
    t.index ["moderatable_type", "moderatable_id"], name: "index_moderation_scores_on_moderatable"
  end

  create_table "newsletter_existing_posts_with_new_replies", force: :cascade do |t|
    t.bigint "newsletter_id", null: false
    t.bigint "post_id", null: false
    t.index ["newsletter_id"], name: "index_newsletter_existing_posts_new_replies_on_newsletter_id"
    t.index ["post_id"], name: "index_newsletter_existing_posts_with_new_replies_on_post_id"
  end

  create_table "newsletter_new_members", force: :cascade do |t|
    t.bigint "newsletter_id", null: false
    t.bigint "member_id", null: false
    t.index ["member_id"], name: "index_newsletter_new_members_on_member_id"
    t.index ["newsletter_id"], name: "index_newsletter_new_members_on_newsletter_id"
  end

  create_table "newsletter_posts", force: :cascade do |t|
    t.bigint "newsletter_id", null: false
    t.bigint "post_id", null: false
    t.index ["newsletter_id"], name: "index_newsletter_posts_on_newsletter_id"
    t.index ["post_id"], name: "index_newsletter_posts_on_post_id"
  end

  create_table "newsletters", force: :cascade do |t|
    t.bigint "member_id"
    t.bigint "previous_newsletter_id"
    t.integer "state", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject"
    t.bigint "community_id"
    t.index ["community_id"], name: "index_newsletters_on_community_id"
    t.index ["member_id"], name: "index_newsletters_on_member_id"
    t.index ["previous_newsletter_id"], name: "index_newsletters_on_previous_newsletter_id"
  end

  create_table "notable_jobs", force: :cascade do |t|
    t.string "note_type"
    t.text "note"
    t.text "job"
    t.string "job_id"
    t.string "queue"
    t.float "runtime"
    t.float "queued_time"
    t.datetime "created_at"
  end

  create_table "notable_requests", force: :cascade do |t|
    t.string "note_type"
    t.text "note"
    t.string "user_type"
    t.bigint "user_id"
    t.text "action"
    t.integer "status"
    t.text "url"
    t.string "request_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.text "params"
    t.float "request_time"
    t.datetime "created_at"
    t.index ["user_type", "user_id"], name: "index_notable_requests_on_user"
  end

  create_table "pay_charges", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "subscription_id"
    t.string "processor_id", null: false
    t.integer "amount", null: false
    t.string "currency"
    t.integer "application_fee_amount"
    t.integer "amount_refunded"
    t.jsonb "metadata"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_account"
    t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
    t.index ["subscription_id"], name: "index_pay_charges_on_subscription_id"
  end

  create_table "pay_customers", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor", null: false
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_account"
    t.index ["owner_type", "owner_id", "deleted_at", "default"], name: "pay_customer_owner_index"
    t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id", unique: true
  end

  create_table "pay_merchants", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "processor", null: false
    t.string "processor_id"
    t.boolean "default"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
  end

  create_table "pay_payment_methods", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "processor_id", null: false
    t.boolean "default"
    t.string "type"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_account"
    t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_subscriptions", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "name", null: false
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.string "status", null: false
    t.datetime "current_period_start", precision: nil
    t.datetime "current_period_end", precision: nil
    t.datetime "trial_ends_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.boolean "metered"
    t.string "pause_behavior"
    t.datetime "pause_starts_at", precision: nil
    t.datetime "pause_resumes_at", precision: nil
    t.decimal "application_fee_percent", precision: 8, scale: 2
    t.jsonb "metadata"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_method_id"
    t.string "stripe_account"
    t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
    t.index ["metered"], name: "index_pay_subscriptions_on_metered"
    t.index ["pause_starts_at"], name: "index_pay_subscriptions_on_pause_starts_at"
  end

  create_table "pay_webhooks", force: :cascade do |t|
    t.string "processor"
    t.string "event_type"
    t.jsonb "event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_member_direct_adds", default: 10000
  end

  create_table "pins", force: :cascade do |t|
    t.string "code", null: false
    t.bigint "member_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_pins_on_member_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.bigint "community_id", null: false
    t.bigint "member_id", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.integer "replies_count", default: 0, null: false
    t.datetime "quarantined_at"
    t.string "prompt"
    t.index ["community_id", "slug"], name: "index_posts_on_community_id_and_slug", unique: true
    t.index ["community_id"], name: "index_posts_on_community_id"
    t.index ["member_id"], name: "index_posts_on_member_id"
    t.index ["quarantined_at"], name: "index_posts_on_quarantined_at"
  end

  create_table "push_notifications", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.bigint "push_subscription_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["push_subscription_id"], name: "index_push_notifications_on_push_subscription_id"
    t.index ["source_type", "source_id"], name: "index_push_notifications_on_source"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.string "endpoint"
    t.string "p256dh"
    t.string "auth"
    t.boolean "subscribed", default: true, null: false
    t.bigint "ahoy_visit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["ahoy_visit_id"], name: "index_push_subscriptions_on_ahoy_visit_id"
    t.index ["member_id", "endpoint"], name: "index_push_subscriptions_on_member_id_and_endpoint", unique: true
    t.index ["member_id"], name: "index_push_subscriptions_on_member_id"
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "member_id", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "quarantined_at"
    t.index ["member_id"], name: "index_replies_on_member_id"
    t.index ["post_id", "slug"], name: "index_replies_on_post_id_and_slug", unique: true
    t.index ["post_id"], name: "index_replies_on_post_id"
    t.index ["quarantined_at"], name: "index_replies_on_quarantined_at"
  end

  create_table "searchable_contents", force: :cascade do |t|
    t.bigint "community_id", null: false
    t.string "content_type", null: false
    t.bigint "content_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.vector "embedding", limit: 3072
    t.text "document"
    t.index ["community_id"], name: "index_searchable_contents_on_community_id"
    t.index ["content_type", "content_id"], name: "index_searchable_contents_on_content"
  end

  create_table "searches", force: :cascade do |t|
    t.string "query", null: false
    t.bigint "member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.vector "embedding", limit: 3072
    t.index ["member_id"], name: "index_searches_on_member_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "verifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "document_address"
    t.jsonb "document_dob"
    t.jsonb "document_issued_date"
    t.string "stripe_verification_id"
    t.string "document_first_name"
    t.string "document_last_name"
    t.string "document_issuing_country"
    t.string "document_number"
    t.string "document_type"
    t.bigint "person_id", null: false
    t.jsonb "document_expiration_date"
    t.index ["document_issuing_country", "document_number", "document_type"], name: "index_verifications_on_document_details"
    t.index ["document_issuing_country"], name: "index_verifications_on_document_issuing_country"
    t.index ["document_number"], name: "index_verifications_on_document_number"
    t.index ["document_type"], name: "index_verifications_on_document_type"
    t.index ["person_id"], name: "index_verifications_on_person_id"
    t.index ["stripe_verification_id"], name: "index_verifications_on_stripe_verification_id", unique: true
  end

  create_table "views", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.string "viewable_type", null: false
    t.bigint "viewable_id", null: false
    t.bigint "ahoy_visit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ahoy_visit_id"], name: "index_views_on_ahoy_visit_id"
    t.index ["member_id"], name: "index_views_on_member_id"
    t.index ["viewable_type", "viewable_id"], name: "index_views_on_viewable_type_and_viewable_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "communities"
  add_foreign_key "activities", "members"
  add_foreign_key "ahoy_messages", "communities"
  add_foreign_key "ahoy_messages", "newsletters", validate: false
  add_foreign_key "api_keys", "communities"
  add_foreign_key "communities", "posts", column: "pinned_post_id", on_delete: :nullify, validate: false
  add_foreign_key "domains", "communities"
  add_foreign_key "follows", "members"
  add_foreign_key "login_activities", "communities"
  add_foreign_key "members", "people", on_delete: :nullify
  add_foreign_key "mentions", "members"
  add_foreign_key "newsletter_existing_posts_with_new_replies", "newsletters"
  add_foreign_key "newsletter_existing_posts_with_new_replies", "posts"
  add_foreign_key "newsletter_new_members", "members"
  add_foreign_key "newsletter_new_members", "newsletters"
  add_foreign_key "newsletter_posts", "newsletters"
  add_foreign_key "newsletter_posts", "posts"
  add_foreign_key "newsletters", "communities", validate: false
  add_foreign_key "newsletters", "members"
  add_foreign_key "newsletters", "newsletters", column: "previous_newsletter_id"
  add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
  add_foreign_key "pay_charges", "pay_subscriptions", column: "subscription_id"
  add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
  add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
  add_foreign_key "pins", "members"
  add_foreign_key "posts", "communities"
  add_foreign_key "posts", "members"
  add_foreign_key "push_notifications", "push_subscriptions"
  add_foreign_key "push_subscriptions", "ahoy_visits"
  add_foreign_key "push_subscriptions", "members"
  add_foreign_key "replies", "members"
  add_foreign_key "replies", "posts"
  add_foreign_key "searchable_contents", "communities"
  add_foreign_key "searches", "members"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "verifications", "people"
  add_foreign_key "views", "ahoy_visits"
  add_foreign_key "views", "members"
end
