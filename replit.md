# Chatwoot - Customer Support Platform

## Overview
Chatwoot is an open-source customer support platform that provides multi-channel communication, AI-powered support agents, team collaboration tools, and comprehensive reporting features. This is a Ruby on Rails 7.1 + Vue.js 3 application.

## Project Status
**Current State:** ✅ **FULLY DEPLOYED AND RUNNING**

The application has been successfully set up and deployed on Replit:
- ✅ Node.js 23.11.1 installed
- ✅ pnpm 10.2.0 and all Node dependencies installed
- ✅ Ruby 3.2.2 with all gems installed (including native extensions)
- ✅ PostgreSQL database configured with Neon backend
- ✅ Database migrations completed successfully (67 migrations)
- ✅ Redis server running on localhost:6379
- ✅ Vite production assets built and optimized
- ✅ Rails/Puma server running on port 5000
- ✅ Super admin account created
- ✅ **Development environment accessible via webview**
- ✅ **Ready for production deployment**

## Access Information

### Super Admin Console
- **URL:** `/super_admin`
- **Email:** admin@example.com
- **Password:** Chatwoot123!

Use the super admin console to manage the platform, view system information, and configure accounts.

### Regular User Login
- **URL:** `/app/login`

Users can create accounts through the signup flow or via super admin console.

## Recent Changes (October 7, 2025)

### AISATURN Branding Implementation
**Status:** ✅ **COMPLETE - Full White-Label Branding**

All Chatwoot branding has been replaced with AISATURN branding across the platform:

**Configuration Updates:**
- `installation_config.yml` updated with AISATURN values:
  - INSTALLATION_NAME: 'AISATURN'
  - LOGO: '/brand-assets/new_logo.png' (renkli logo)
  - LOGO_DARK: '/brand-assets/new_logo_dark.png' (beyaz logo)
  - LOGO_THUMBNAIL: '/aisaturn_favicon.png'
  - BRAND_NAME: 'AISATURN'
  - BRAND_URL: 'https://merchant.aisaturn.co'
  - WIDGET_BRAND_URL: 'https://merchant.aisaturn.co'

**Assets:**
- Logo files downloaded from merchant.aisaturn.co
- Favicon updated across all sizes (16x16, 32x32, 96x96, 512x512)
- All assets verified accessible via HTTP 200 OK

**UI Updates:**
- Super Admin Console: Logo and text updated to AISATURN
- Login page: "Login to AISATURN" heading
- Database InstallationConfig records synced

**Location:**
- Config: `config/installation_config.yml`
- Logos: `public/brand-assets/new_logo.png`, `new_logo_dark.png`
- Favicon: `public/aisaturn_favicon.png`
- Super Admin: `app/views/super_admin/application/_navigation.html.erb`

## Recent Changes (October 6, 2025)

### Saturn AI - MIT-Licensed Auto-Response System
**Status:** ✅ **COMPLETE - Backend + Frontend + UI**

Saturn AI is a new MIT-licensed automatic response system built as an alternative to Captain AI (enterprise feature). It provides AI-powered automatic responses using OpenAI integration.

**Architecture:**
- **Database:** 3 core tables (saturn_agent_profiles, saturn_knowledge_sources, saturn_inbox_connections)
- **Backend Models:** Saturn::AgentProfile, Saturn::KnowledgeSource, Saturn::InboxConnection
- **Services:** Saturn::Orchestrator (multi-turn conversation handler), Saturn::LlmService (OpenAI integration)
- **API Endpoints:** Full CRUD for agents, knowledge sources, inbox connections
- **Frontend:** Main sidebar menu "Saturn" (✨ sparkles icon, above Contacts)

**UI Features (Captain AI Style):**
- **Agent Management:** PageLayout with card-based agent list, dialog-based create/edit/delete
- **Knowledge Sources:** Full CRUD for documents/FAQs with agent filtering
  - Text/Document, URL/Website, FAQ source types
  - Edit and delete actions on each knowledge card
  - Agent-specific knowledge base pages
- **Inbox Connections:** Connect agents to specific inboxes for auto-response
- **Custom Components:** AgentCard, CreateAgentDialog, DeleteAgentDialog, EmptyState
- **API Client:** Uses Chatwoot ApiClient pattern for proper authentication

**MIT Compliance:**
- Distinct table names (saturn_* vs captain_*)
- Different class structure (AgentProfile vs Assistant, KnowledgeSource vs Document)
- Separate namespacing and tool system
- No enterprise folder dependencies

**Requirements:**
- OpenAI API key configured via Super Admin > Accounts > Edit Account
- PostgreSQL with pgvector extension (for embeddings)

**Location:**
- API: `/api/v1/accounts/:account_id/saturn/`
- Frontend: Main sidebar > Saturn (✨ icon)
- Routes: 
  - `/accounts/:accountId/settings/saturn-agents` - Agent list
  - `/accounts/:accountId/settings/saturn-agents/:agentId/knowledge-sources` - Knowledge sources
  - `/accounts/:accountId/settings/saturn-agents/:agentId/inbox-connections` - Inbox connections

**Auto-Response System:**
- **Automatic Message Handling:** When a message arrives in a connected inbox, Saturn automatically generates and sends AI-powered responses
- **Event-Driven Architecture:** Uses SaturnListener to detect incoming messages and trigger Saturn::AutoRespondJob
- **Duplicate Prevention:** Idempotency checks prevent multiple responses to the same message
- **Robust Sender Selection:** Fallback hierarchy (assignee → inbox member → admin) ensures messages are always sent
- **Knowledge Integration:** Uses search_knowledge_base tool to fetch relevant information from FAQ/documents

**Recent Updates:**
- **October 6, 2025:** Removed Auto Replies feature (redundant with Knowledge Sources FAQ system) - simplified to focus on AI-powered responses via knowledge base
- **October 6, 2025:** Implemented automatic response system with SaturnListener and AutoRespondJob for real-time AI-powered customer support

### CI/CD Pipeline Setup
1. **GitHub Actions deployment:** Automated deployment pipeline configured for main branch pushes
2. **Digital Ocean integration:** SSH deployment to production server (app.aisaturn.co)
3. **SSH key authentication:** Production server SSH key passphrase removed for automated deployments

### Critical Issues Resolved
1. **Database migration SIGHUP error:** Removed `db:migrate` from `start_app.sh` startup script to prevent SignalException during workflow restart
2. **Workflow startup optimization:** Streamlined startup to only start Redis, Sidekiq, and Puma (migrations managed separately)
3. **Vite on-demand compilation:** Confirmed Vite assets compile successfully on first request (7-10 second initial load time is expected)

### Previous Setup (October 5, 2025)
1. **Port binding conflict:** Fixed duplicate `bind` directive in `config/puma.rb` that caused "Address already in use" error
2. **Rack::File error:** Updated `rack-mini-profiler` from 3.2.0 to 4.0.1 for Rack 3 compatibility
3. **Native gem installation:** Successfully configured bundle with PostgreSQL library paths from Nix store
4. **Setup page override:** Moved `public/index.html` placeholder to backup to reveal actual application

### Configuration Changes
- Modified Ruby version in Gemfile from 3.4.4 to 3.2.2 (matches available Replit module)
- Configured Puma to bind only once on port 5000
- Installed system dependencies: postgresql_16, openssl, pkg-config, gcc, gnumake, autoconf, redis
- Created `.env` file with proper database and Redis configuration
- Optimized `start_app.sh` script: removed db:migrate (prevents SIGHUP), added port cleanup

### Database Setup
- Created PostgreSQL database via Replit's Neon service
- Ran all migrations successfully (67 migrations completed - synced with production)
- Database schema loaded and ready for use
- Development database separate from production (Digital Ocean)

## Project Architecture

### Backend (Ruby on Rails 7.1)
- **Framework:** Ruby on Rails 7.1.5.2
- **Database:** PostgreSQL 16 (via Neon/Replit database)
- **Background Jobs:** Sidekiq with Redis
- **Real-time:** ActionCable for WebSocket connections
- **API:** RESTful API with token authentication
- **Server:** Puma (single mode, 5 threads)

### Frontend (Vue.js 3)
- **Framework:** Vue 3 with Composition API
- **Build Tool:** Vite 5.4.20 (via vite_rails gem)
- **State Management:** Vuex
- **Router:** Vue Router
- **Styling:** Tailwind CSS
- **Dev Integration:** Vite compiles on-demand for Rails views

### Key Configuration Files
- `start_app.sh` - Application startup script (workflow entry point)
- `config/puma.rb` - Puma web server configuration
- `vite.config.ts` - Vite bundler configuration (configured for Replit proxy)
- `config/database.yml` - Database configuration
- `.env` - Environment variables (not committed to git)

## Running the Application

The application automatically starts via the "Chatwoot" workflow which runs:
```bash
bash start_app.sh
```

This script:
1. Cleans up any existing process on port 5000
2. Starts Redis server if not running
3. Loads or generates persistent SECRET_KEY_BASE (stored in .secret_key_base)
4. Exports required environment variables
5. Starts Sidekiq background worker (for email, automations, jobs)
6. Starts Puma web server on port 5000

The application is accessible through Replit's webview proxy.

**Note on Vite:** The frontend uses Vite for asset compilation, which runs on-demand when Rails requests assets. A separate Vite dev server is not needed in this configuration.

## Port Configuration
- **Port 5000:** Rails/Puma server (only non-firewalled port in Replit)
- **Port 6379:** Redis server (localhost only)

## Environment Variables

Database configuration (auto-configured by Replit):
- `POSTGRES_HOST` - from $PGHOST
- `POSTGRES_USERNAME` - from $PGUSER
- `POSTGRES_PASSWORD` - from $PGPASSWORD
- `POSTGRES_DATABASE` - from $PGDATABASE
- `POSTGRES_PORT` - from $PGPORT

Application configuration (set in start_app.sh):
- `SECRET_KEY_BASE` - Persistent key stored in .secret_key_base (never commit this file!)
- `FRONTEND_URL` - http://localhost:5000
- `RAILS_ENV` - development
- `REDIS_URL` - redis://localhost:6379
- `PORT` - 5000

## Security Considerations

⚠️ **IMPORTANT SECURITY NOTES:**

1. **Never commit `.env` or `.secret_key_base` files** - These contain sensitive credentials
2. **Change default super admin password** - The default password should be changed immediately after first login
3. **Secrets Management** - Use Replit's Secrets feature for production deployments
4. **Database Credentials** - Already managed securely by Replit's environment variables

The `.gitignore` file has been configured to exclude:
- `.env`
- `.secret_key_base`
- Other sensitive configuration files

## Technology Stack
- **Ruby:** 3.2.2
- **Rails:** 7.1.5.2
- **Node.js:** 23.11.1
- **Vue.js:** 3.5
- **PostgreSQL:** 16.9 (Neon)
- **Redis:** Latest via Nix
- **Vite:** 5.4.20
- **Puma:** 6.4.3
- **Tailwind CSS:** 3.x
- **Sidekiq:** 7.3.1

## Known Limitations

### Performance
- **First load:** Vite build can take 60-90 seconds on initial page load
- **Subsequent loads:** 4-8 seconds for cached assets
- This is expected behavior in development mode with on-demand compilation

### Development Environment
- Running in development mode (not production-optimized)
- Vite serves unminified assets for easier debugging
- Database migrations run via schema load (not individual migrations)

## Next Steps for Production

To prepare for production deployment:

1. **Environment Variables:**
   - Set persistent SECRET_KEY_BASE
   - Configure email service (SMTP settings)
   - Add storage service (AWS S3 or similar) for attachments

2. **Asset Compilation:**
   - Run `bundle exec rake assets:precompile`
   - Use production-mode Vite build

3. **Background Workers:**
   - Ensure Sidekiq is running as separate process
   - Configure Sidekiq monitoring

4. **Security:**
   - Change super admin password
   - Configure SSL/TLS
   - Set up CORS policies for API access

## Resources
- [Chatwoot Documentation](https://www.chatwoot.com/docs)
- [Chatwoot GitHub](https://github.com/chatwoot/chatwoot)
- [Environment Variables Guide](https://www.chatwoot.com/docs/self-hosted/configuration/environment-variables/)
- [Self-Hosted Installation Guide](https://www.chatwoot.com/docs/self-hosted)

## Troubleshooting

### Application won't start
- Check Redis is running: `redis-cli ping`
- Verify database connection: Check logs for connection errors
- Ensure port 5000 is not in use by another process

### Slow page loads
- First Vite build takes time (60-90s) - this is normal
- Check Rails logs: `tail -f log/development.log`
- Verify assets are being compiled: Look for Vite output in logs

### Database errors
- Migrations should be up-to-date: `bundle exec rails db:migrate:status`
- Check database connectivity: Ensure Replit database is active

## User Preferences
- Running in development mode for easier debugging and iteration
- Using Replit's managed PostgreSQL (Neon) for database
- Single-process Puma configuration (suitable for development)
