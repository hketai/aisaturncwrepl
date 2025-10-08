# Chatwoot - Customer Support Platform

## Overview
Chatwoot is an open-source, multi-channel customer support platform built with Ruby on Rails 7.1 and Vue.js 3. It offers AI-powered support, team collaboration, and comprehensive reporting. This project has been white-labeled as "AISATURN" and includes a custom MIT-licensed AI auto-response system called Saturn AI, developed as an alternative to enterprise solutions. The platform aims to provide a distinct, branded customer support experience ready for production deployment.

## User Preferences
- Running in development mode for easier debugging and iteration
- Using Replit's managed PostgreSQL (Neon) for database
- Single-process Puma configuration (suitable for development)
- Minimal color palette with high contrast for accessibility
- Clean, professional design with #3072ff primary blue

## System Architecture

### UI/UX Decisions
The platform features a completely redesigned visual identity distinct from Chatwoot, with a minimal and professional design system.

**Simplified Design System (October 8, 2025):**
- **Primary Color:** #3072ff blue for all interactive elements (buttons, links, accents)
- **Color Palette:** Minimalist approach - only blue (#3072ff) and neutral grays, no multi-color scheme
- **Contrast:** Enhanced text contrast for better readability in light mode (slate-11/slate-12 for text)
- **Backgrounds:** Clean white/slate with subtle gradients for depth
- **Status Colors:** Minimal set - success (green), warning (amber), error (red) only when necessary

**Component Design System:**
- **Buttons:** #3072ff blue, semibold text, smooth transitions, shadow-sm elevation
- **Active States:** Blue backgrounds with proper contrast ratios
- **Hover Effects:** Subtle slate-2/slate-3 backgrounds with smooth 200ms transitions
- **Accent Bars:** 1px wide blue indicators on active sidebar items
- **Typography:** Semibold fonts (13-14px) for better hierarchy

**Navigation:**
- **Top Navbar:** Horizontal navigation with blue active states
- **Sidebar:** Minimal design with blue accent system
- **Menu Structure:** Simplified - removed Inbox View, Campaigns (Live Chat/SMS), Help Center/Portals, and Integrations

**Branding:**
- Replaced all Chatwoot branding with "AISATURN" logos and text
- Custom favicon and logo assets throughout platform
- Consistent AISATURN naming across development and production

### Technical Implementations
- **Backend:** Ruby on Rails 7.1.5.2, PostgreSQL 16, Sidekiq for background jobs, ActionCable for real-time features, RESTful API with token authentication, Puma web server.
- **Frontend:** Vue 3 with Composition API, Vite 5.4.20 for asset building (pre-built on startup to avoid conflicts), Vuex for state management, Vue Router, and Tailwind CSS for styling.
- **Performance Optimizations:**
    - **GlobalConfig:** Batch-fetch implementation using Redis mget and single SQL WHERE IN query (reduced from 21 sequential queries to 1)
    - **Portal Lookups:** Memoized to prevent duplicate database queries per request
    - **Startup:** Vite builds assets once during startup to prevent on-demand build conflicts
- **Saturn AI (MIT-Licensed Auto-Response System):**
    - **Architecture:** Uses `saturn_*` database tables (`saturn_agent_profiles`, `saturn_knowledge_sources`, `saturn_inbox_connections`), dedicated backend models, and services like `Saturn::Orchestrator` (multi-turn conversation) and `Saturn::LlmService` (OpenAI integration).
    - **Features:** Full CRUD for agents, knowledge sources (Text/Document, URL, FAQ), and inbox connections. Includes UI for agent management, knowledge base configuration, and connecting agents to inboxes.
    - **Auto-Response Mechanism:** Event-driven system using `SaturnListener` and `Saturn::AutoRespondJob` to provide AI-powered responses to incoming messages in connected inboxes, leveraging a knowledge base for relevant information.
    - **AI Conversation Limits:** Account-level limits with fields `ai_conversation_limit`, `ai_conversation_count`, and `ai_limit_reset_at`. Saturn::AutoRespondJob enforces limits before responding, with automatic monthly reset. Frontend displays warning banner at ≥80% usage.
- **InstallationConfig (Configuration Management):**
    - **Serialization:** Uses JSONB column with YAML serialization (`serialize :serialized_value, coder: YAML`). Values stored as YAML strings inside JSONB.
    - **Setting Values:** Always use `config.value = 'new_value'` which properly wraps in YAML format. Never use direct SQL with JSON format.
    - **Deployment:** Automated branding configuration in `.github/workflows/deploy.yml` uses Rails model methods to ensure proper YAML serialization.
- **CI/CD:** Automated deployment pipeline via GitHub Actions to Digital Ocean, using SSH key authentication.
- **Configuration:** Optimized `start_app.sh` script for workflow entry (Vite build → Sidekiq → Puma), `config/puma.rb` for server, `vite.config.ts` for frontend, and `.env` for environment variables.

### Feature Specifications
- **AISATURN Branding:** Full white-label branding implemented with consistent naming.
- **Saturn AI:** Provides AI-powered auto-responses using OpenAI, with distinct architectural components and UI for managing agents, knowledge sources, and inbox connections.
- **Multi-channel Communication:** Core Chatwoot functionality for managing customer interactions across various channels.
- **Team Collaboration:** Tools for agents to collaborate on customer support tickets.
- **Reporting:** Comprehensive features for tracking and analyzing support performance.

## External Dependencies
- **PostgreSQL 16:** Database, provided via Replit's Neon service. Requires `pgvector` extension for AI embeddings. Note: Development may experience latency (~1-3s per request) due to Neon free tier network distance.
- **Redis:** Used for Sidekiq background jobs and GlobalConfig caching.
- **OpenAI:** Integrated for the Saturn AI auto-response system's LLM capabilities. Requires an OpenAI API key.
- **Node.js 23.11.1 & pnpm 10.2.0:** For frontend development and asset compilation.
- **Ruby 3.2.2:** Core backend language runtime.
- **Vite 5.4.20:** Frontend build tool, integrated via `vite_rails` gem. Builds once on startup to prevent conflicts.
- **Tailwind CSS:** For styling the frontend with custom color system.
- **Puma 6.4.3:** Web server for the Rails application.
- **Sidekiq 7.3.1:** Background job processor.

## Known Issues & Notes
- **Development Performance:** Neon PostgreSQL (free tier) has network latency (~1-3s per request). Production deployment will be significantly faster with premium tier or closer edge locations.
- **Database Optimizations:** GlobalConfig and Portal queries are fully optimized with batch fetching and memoization. Any remaining slowness is infrastructure-related.
