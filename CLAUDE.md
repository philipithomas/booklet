# Booklet (BKLT)

Community discussion platform built with Rails 7.2. Supports two modes: **solo** (single community, default) and **multiuser** (multi-tenant SaaS).

## Key Commands

```bash
# Development
./bin/dev-solo              # Start in solo mode (single community, no subdomains)
./bin/dev-multiuser         # Start in multiuser mode (subdomains, billing)
bundle exec rails console   # Rails console
bundle exec rake solid_queue:start  # Background jobs

# Testing
bundle exec rails test:all  # All Rails tests (minitest)
bundle exec rails test test/models/member_test.rb  # Specific file
bundle exec rails test test/models/member_test.rb:42  # Specific test
bundle exec rspec            # API specs (RSpec)
APP_MODE=SOLO bundle exec rails test:all  # Test in solo mode

# Linting & Security
./bin/rubocop               # Rubocop (standardrb-based)
bundle exec brakeman        # Security scan
bundle exec bundle-audit check  # Dependency audit
bundle exec i18n-tasks health   # i18n completeness

# API docs
bundle exec rake rswag:specs:swaggerize
```

## Architecture

### Application Modes

Set via `APP_MODE` environment variable (default: `SOLO`). Configuration lives in `config/initializers/00_app_config.rb`.

- **Solo mode**: `Rails.configuration.solo_mode == true`
  - Single community, `Community.first` always used
  - All routes on one host (no subdomains)
  - Stripe billing bypassed (`active_subscription?` always true)
  - Editor admin panel disabled
  - hCaptcha skipped

- **Multiuser mode**: `Rails.configuration.multiuser_mode == true`
  - Communities resolved by subdomain or custom domain
  - Stripe subscriptions required
  - Editor panel at `editor.` subdomain
  - Community creation at `new.` subdomain

### Core Models

- **Community** — tenant/organization. Has members, posts, domains, newsletters. Uses FriendlyId for slugs.
- **Member** — user within a community. Devise auth (email/password). Scoped uniqueness: email per community. Permissions: member, manager, admin.
- **Post** — discussion thread with rich text (ActionText). Has replies, views, follows.
- **Reply** — comment on a post.
- **Newsletter** — weekly email digest per community. AI-generated summaries when OpenAI configured.
- **Domain** — custom domain mapping for communities (multiuser).
- **SearchableContent** — indexable documents for semantic search; embeddings are stored in Chroma.
- **Editor** — separate auth model for internal admin panel (multiuser only).

### Background Jobs (Solid Queue)

- `EnqueueNewslettersJob` — daily, checks if communities have newsletters scheduled
- `GenerateNewsletterJob` — creates newsletter content with AI summaries
- `ModerationJob` — OpenAI content moderation (skipped when OpenAI not configured)
- `SearchableContentJob` — generates embeddings (skipped when OpenAI not configured)
- `VerifyDomainsJob` — checks custom domain DNS (skipped in solo mode)
- `CleanupTrackingDataJob` — purges old analytics data
- `PublishedPostNotificationJob` / `PublishedReplyNotificationJob` — push + email notifications

### Service Availability

External services degrade gracefully. Guards use `ServiceAvailable` module (`app/models/concerns/service_available.rb`):

```ruby
ServiceAvailable.openai?   # ENV["OPENAI_API_KEY"] present?
ServiceAvailable.chroma?   # ENV["CHROMA_HOST"] present?
ServiceAvailable.postmark? # ENV["POSTMARK_API_TOKEN"] present?
ServiceAvailable.stripe?   # multiuser mode?
ServiceAvailable.hcaptcha? # both hCaptcha keys present?
```

### Important Patterns

**Mode-specific behavior:**
```ruby
if Rails.configuration.solo_mode
  @community = Community.first
else
  # resolve by subdomain/custom domain
end
```

**Community resolution** in `ApplicationController#set_community`:
- Solo: `Community.first`
- Multiuser: subdomain → slug lookup, or custom domain → Domain lookup

**Email sending**: `ApplicationMailer` with community-aware from addresses. Reply-to uses configurable `SUPPORT_EMAIL`.

### Frontend Stack

- Tailwind CSS (via tailwindcss-rails)
- Stimulus.js controllers
- Turbo (Hotwire) for SPA-like navigation
- jsbundling-rails with Webpack
- ActionText / Trix for rich text editing

### File Storage

- Development: local disk (`storage/`)
- Production: AWS S3 (via Active Storage)

### Email

- Development: letter_opener (auto-opens in browser) when Postmark not configured
- Production: Postmark
- Tracking: ahoy_email for opens/clicks

### API

REST API with Swagger/OpenAPI docs via rswag. In multiuser mode it is served on the `api.` subdomain (`/members`); in solo mode it lives under `/api` (`/api/members`) with docs at `/api-docs`.

## Environment Variables

All optional for development. See `.env.sample` for the full list. Key ones:
- `APP_MODE` — `SOLO` or `MULTIUSER`
- `OPENAI_API_KEY` — enables AI features
- `POSTMARK_API_TOKEN` — email delivery
- `SUPPORT_EMAIL` / `ADMIN_EMAIL` — configurable contact addresses
