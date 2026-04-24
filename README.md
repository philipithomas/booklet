# Booklet (BKLT)

Booklet is an open-source community discussion platform I built from 2023 to 2024. It was designed for *asynchronous* communication, and sent an AI-generated email newsletter based on discussions so that members could stay engaged without staying logged-in.

It supports threaded discussions, newsletters with AI-generated summaries, member management, custom domains, content moderation, and semantic search.

> **Note:** Booklet was previously a hosted service at booklet.group which is no longer operating. This open-source release allows anyone to run their own community platform.

## Running Booklet in Solo Mode (Recommended)

Solo mode runs a single community on a single domain — no subdomains, no billing, no editor admin panel. This is the simplest way to run Booklet.

### Requirements

- Ruby 3.2.2
- Rails 7.2
- PostgreSQL with the [pgvector](https://github.com/pgvector/pgvector) extension
- Node.js 18+ and Yarn
- [libvips](https://www.libvips.org/) for image processing

### Quick Start

```bash
git clone https://github.com/philipithomas/bklt.git
cd bklt
bundle install
yarn install
rails db:create db:schema:load db:seed
./bin/dev-solo
```

Visit [http://localtest.me:3000](http://localtest.me:3000). Sign in with `admin@example.com` / `password`.

### Environment Variables

Copy `.env.sample` to `.env` and configure as needed. **All variables are optional for local development** — the app boots with sensible defaults.

| Variable | Description | Required |
|----------|-------------|----------|
| `APP_MODE` | `SOLO` (default) or `MULTIUSER` | No |
| `BASE_HOST` | Application hostname (default: `localtest.me`) | No |
| `POSTMARK_API_TOKEN` | Email delivery via Postmark | No (uses letter_opener in dev) |
| `OPENAI_API_KEY` | Enables content moderation, newsletter summaries, semantic search | No |
| `OPENAI_ORG_ID` | OpenAI organization ID | No |
| `CHROMA_HOST` | Chroma vector DB for semantic search | No |
| `CHROMA_API_KEY` | Chroma API key | No |
| `AWS_ACCESS_KEY_ID` | S3 file storage (production) | No (uses local disk in dev) |
| `AWS_SECRET_ACCESS_KEY` | S3 secret | No |
| `AWS_REGION` | S3 region (default: `us-west-1`) | No |
| `AWS_STORAGE_BUCKET` | S3 bucket name | No |
| `HCAPTCHA_SITE_KEY` | Bot protection for forms | No |
| `HCAPTCHA_SECRET_KEY` | hCaptcha secret | No |
| `ADMIN_EMAIL` | Admin notification recipient | No |
| `SUPPORT_EMAIL` | Support email shown to users | No |
| `ADMIN_CHAT_URL` | Webhook URL for admin notifications (Discord/Slack) | No |
| `JUNK_DRAWER_API_URL` | External newsletter signup API | No |
| `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY` | AR encryption (run `rails db:encryption:init`) | Production only |
| `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY` | AR encryption | Production only |
| `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT` | AR encryption | Production only |

### Optional Services

Booklet gracefully degrades when optional services are not configured:

- **OpenAI**: Without it, content moderation is skipped, newsletters use simple subjects, and semantic search is disabled. Basic name search still works.
- **Chroma**: Without it, vector-based semantic search is disabled.
- **Postmark**: Without it, development uses letter_opener (emails open in browser). For production, configure Postmark or modify `config/application.rb` to use another delivery method.
- **AWS S3**: Without it, file uploads are stored on local disk (fine for development).

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

### Pre-commit Hooks

Install [Lefthook](https://github.com/evilmartians/lefthook) for automatic linting:

```bash
brew install lefthook
lefthook install
```

## Production Hosting

### Docker

The included `Dockerfile` builds a production-ready image:

```bash
docker build -t booklet .
docker run -e DATABASE_URL=postgres://... -e SECRET_KEY_BASE=... -e APP_MODE=SOLO -p 3000:3000 booklet
```

### Render

A `render.yaml` is included for one-click deployment to [Render](https://render.com). It configures PostgreSQL and sets `APP_MODE=SOLO` by default. You'll need to manually configure service credentials (Postmark, AWS, etc.) after deployment.

## Multiuser Mode

Multiuser mode enables the full SaaS feature set: subdomain-based routing, Stripe billing, an editor admin panel, custom domains, and community creation.

```bash
APP_MODE=MULTIUSER ./bin/dev-multiuser
```

In multiuser mode, the app uses subdomains:
- `app.localtest.me` — main app
- `new.localtest.me` — community signup
- `editor.localtest.me` — internal admin
- `api.localtest.me` — REST API with Swagger docs

Additional environment variables for multiuser mode:
- `STRIPE_PLAN_ID` — Stripe subscription price ID
- `FLY_API_TOKEN` / `FLY_APP_ID` — Custom domain certificate management

## License

Booklet is licensed under the [MIT License](LICENSE).
