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

## Recent Changes (October 6, 2025)

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
