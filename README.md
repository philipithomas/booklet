# Booklet (BKLT)

Booklet is an open-source community discussion platform I built from 2023 to 2024. It was designed for *asynchronous* communication, and sent an AI-generated email newsletter based on discussions so that members could stay engaged without staying logged-in.

It supports threaded discussions, newsletters with AI-generated summaries, member management, custom domains, content moderation, and semantic search.

> **Note:** Booklet was previously a hosted service at booklet.group which is no longer operating. This open-source release allows anyone to run their own community platform.

[Fork it](https://github.com/philipithomas/booklet/fork) and make it your own — solo mode is designed for easy self-hosting with Docker and a Postgres database.

## Running Booklet in Solo Mode (Recommended)

Solo mode runs a single community on a single domain — no subdomains, no billing, no editor admin panel. This is the simplest way to run Booklet.

### Requirements

- Ruby 3.3.5
- Rails 7.2
- PostgreSQL
- Node.js 18+ and Yarn
- [libvips](https://www.libvips.org/) for image processing

### Quick Start

```bash
git clone https://github.com/philipithomas/booklet.git
cd booklet
bundle install
yarn install
rails db:create db:schema:load db:seed
./bin/dev-solo
```

Visit [http://localtest.me:3000](http://localtest.me:3000). Sign in with `admin@example.com` / `password`.

Seeds create demo data with well-known credentials and refuse to run in production — use `rails booklet:bootstrap` for production setup (see [First-run setup](#first-run-setup)).

### Environment Variables

Copy `.env.sample` to `.env` and configure as needed. **All variables are optional for local development** — the app boots with sensible defaults.

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_MODE` | `SOLO` | `SOLO` or `MULTIUSER` |
| `BASE_HOST` | `localtest.me` (dev), `localhost` (prod) | Application hostname — set this in production |
| `SECRET_KEY_BASE` | — | Rails secret for cookies/crypto — generate with `rails secret` (production only) |
| `DATABASE_URL` | local `config/database.yml` | PostgreSQL connection string (production only) |
| `POSTMARK_API_TOKEN` | — | Email delivery via Postmark (development uses letter_opener when unset) |
| `DEFAULT_EMAIL_FROM` | `no-reply@BASE_HOST` | From address for outgoing email — must be a sender your email provider has verified |
| `ADMIN_EMAIL` | `admin@example.com` | Admin notification recipient |
| `SUPPORT_EMAIL` | `support@example.com` | Support email shown to users |
| `MAILING_ADDRESS` | — | Physical mailing address appended to email footers (e.g. for CAN-SPAM compliance) |
| `OPENAI_API_KEY` | — | Enables content moderation, newsletter summaries, semantic search |
| `OPENAI_ORG_ID` | — | OpenAI organization ID |
| `CHROMA_HOST` | — | Chroma vector DB for semantic search |
| `CHROMA_API_KEY` | — | Chroma API key |
| `CHROMA_TENANT` | — | Chroma tenant (required for Chroma Cloud) |
| `CHROMA_DATABASE` | — | Chroma database name |
| `AWS_ACCESS_KEY_ID` | — | S3 file storage (production; development uses local disk) |
| `AWS_SECRET_ACCESS_KEY` | — | S3 secret |
| `AWS_REGION` | `us-west-1` | S3 region |
| `AWS_STORAGE_BUCKET` | — | S3 bucket name |
| `HCAPTCHA_SITE_KEY` | — | Bot protection for forms |
| `HCAPTCHA_SECRET_KEY` | — | hCaptcha secret |
| `ADMIN_CHAT_URL` | — | Webhook URL for admin notifications (Discord/Slack). Signup notifications include member email addresses |
| `TRUEMAIL_VERIFIER_EMAIL` | `hello@example.com` | From-address used for SMTP email validation |
| `PLAUSIBLE_SCRIPT_URL` | — | Optional Plausible analytics script URL (production only; no analytics when unset) |
| `JUNK_DRAWER_API_URL` | — | External newsletter signup API |
| `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY` | dev/test default | AR encryption — **required in production** (the app won't boot without it). Generate with `rails db:encryption:init` |
| `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY` | dev/test default | AR encryption — required in production |
| `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT` | dev/test default | AR encryption — required in production |

### Optional Services

Booklet gracefully degrades when optional services are not configured:

- **OpenAI**: Without it, content moderation is skipped, newsletters use simple subjects, and semantic search is disabled. Basic name search still works.
- **Chroma**: Without it, vector-based semantic search is disabled.
- **Postmark**: Without it, development uses letter_opener (emails open in browser). For production, see [Production email](#production-email-postmark).
- **AWS S3**: Without it, file uploads are stored on local disk (fine for development).
- **MaxMind GeoLite2**: IP geolocation for visit analytics. The database cannot be redistributed with this repo — [download it with a free MaxMind license key](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data) and place it at `config/data/GeoLite2-City.mmdb`. Geocoding is skipped when the file is absent.

## Development

```bash
./bin/dev-solo      # Start in solo mode
./bin/dev-multiuser # Start in multiuser mode
```

### Testing

```bash
bundle exec rails test:all  # Rails tests
bundle exec rspec            # API specs
bundle exec brakeman         # Security scan
./bin/rubocop                # Linting
```

### REST API

In solo mode the REST API is served under `/api` with interactive docs at `/api-docs`. In multiuser mode it lives on the `api.` subdomain. Manage API keys per community at Settings → API keys.

### Pre-commit Hooks

Install [Lefthook](https://github.com/evilmartians/lefthook) for automatic linting:

```bash
brew install lefthook
lefthook install
```

## Production Hosting

Background jobs (newsletters, moderation, notifications) run via Solid Queue inside the Puma process (`plugin :solid_queue` in `config/puma.rb`) — no separate worker process is required.

### Docker

The included `Dockerfile` builds a production-ready image:

```bash
docker build -t booklet .
docker run \
  -e DATABASE_URL=postgres://... \
  -e SECRET_KEY_BASE=... \
  -e ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=... \
  -e ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=... \
  -e ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=... \
  -e APP_MODE=SOLO \
  -e BASE_HOST=community.example.com \
  -p 3000:3000 booklet
```

Generate the encryption keys with `rails db:encryption:init` and `SECRET_KEY_BASE` with `rails secret`.

### Render

A `render.yaml` is included for deployment to [Render](https://render.com). It provisions PostgreSQL, generates the secret keys, and sets `APP_MODE=SOLO` by default. You'll need to manually configure `BASE_HOST` and service credentials (Postmark, AWS, etc.) after deployment. Note that the blueprint uses paid plans (`standard` web service, `basic-256mb` database) — adjust to your budget.

### First-run setup

A freshly migrated production database has no community or admin yet (`db:seed` is development-only demo data and refuses to run in production). Create them with:

```bash
COMMUNITY_NAME="My Community" ADMIN_EMAIL=you@example.com bundle exec rails booklet:bootstrap
```

The task prints a generated admin password (or set `ADMIN_PASSWORD` yourself). `ADMIN_NAME`, `COMMUNITY_SLUG`, and `COMMUNITY_NAME` are also configurable. Note that `ADMIN_EMAIL` doubles as the notification-recipient setting, so if it's already set in your deployment environment the task will use that address. Sign in with the printed credentials and you're ready to go.

### Production email (Postmark)

Booklet's flagship feature is the email newsletter, so production deployments need a working email provider:

1. Create a [Postmark](https://postmarkapp.com) account.
2. Verify a sender signature or domain.
3. Set `POSTMARK_API_TOKEN` and set `DEFAULT_EMAIL_FROM` to an address on the verified domain.

To use a different provider, change the delivery method in `config/application.rb`.

## Multiuser Mode

Multiuser mode enables the full SaaS feature set: subdomain-based routing, Stripe billing, an editor admin panel, custom domains, and community creation.

```bash
./bin/dev-multiuser
```

In multiuser mode, the app uses subdomains:
- `app.localtest.me` — main app
- `www.localtest.me` — marketing site
- `new.localtest.me` — community signup
- `editor.localtest.me` — internal admin
- `api.localtest.me` — REST API with Swagger docs
- `index.localtest.me` — public community index
- `delivery.localtest.me` — CDN/asset host (production)
- `<community-slug>.localtest.me` — individual community sites

Additional environment variables for multiuser mode:
- `STRIPE_PRIVATE_KEY` / `STRIPE_PUBLIC_KEY` / `STRIPE_SIGNING_SECRET` — Stripe API keys for billing (used by the [pay](https://github.com/pay-rails/pay) gem)
- `STRIPE_PLAN_ID` — Stripe subscription price ID
- `FLY_API_TOKEN` / `FLY_APP_ID` — Custom domain certificate management
- `APEX_DNS_IP` — IPv4 address shown in customers' apex-domain DNS instructions
- `BUSINESS_NAME` / `BUSINESS_ADDRESS` — Business details shown on Stripe receipts

## License

Booklet is licensed under the [MIT License](LICENSE).
