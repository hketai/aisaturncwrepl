# Chatwoot - Customer Support Platform

## Overview
Chatwoot, rebranded as AISATURN, is an open-source customer support platform built with Ruby on Rails 7.1 and Vue.js 3. It provides multi-channel communication, AI-powered support agents, team collaboration, and reporting. The project's core purpose is to offer a comprehensive, white-label solution for businesses to manage customer interactions efficiently, with a strong focus on AI-driven capabilities to streamline customer support.

## User Preferences
- Running in development mode for easier debugging and iteration
- Using Replit's managed PostgreSQL (Neon) for database
- Single-process Puma configuration (suitable for development)

## System Architecture

### UI/UX Decisions
- **Branding:** Full white-label branding as AISATURN, including logos, favicons, and text across the Super Admin Console, Login page, and Dashboard Sidebar.
- **Iconography:** All icons are Phosphor (ph-thin) for consistency.
- **Menu Structure:** Streamlined sidebar menu includes Conversations, Saturn AI, Contacts, Reports, Settings, and WhatsApp campaigns. Redundant or unused menu items have been removed.
- **Color Scheme:** Consistent button colors for different actions (Blue for primary, Teal for connectivity, Faded Slate for secondary, Ruby for destructive).
- **Dark Mode:** Enhanced readability and visibility for various components in dark mode.

### Technical Implementations
- **AI Auto-Response System (Saturn AI):** MIT-licensed system utilizing OpenAI for AI-powered automatic responses.
    - **Components:** `Saturn::AgentProfile`, `Saturn::KnowledgeSource`, `Saturn::InboxConnection` models; `Saturn::Orchestrator` for multi-turn conversations; `Saturn::LlmService` for OpenAI integration.
    - **Workflow:** Event-driven architecture with `SaturnListener` and `Saturn::AutoRespondJob` for real-time AI responses, including idempotency checks and knowledge base integration.
    - **Intent-Based Routing:** Uses `gpt-3.5-turbo` for intent detection to route conversations to specific teams or agents.
    - **AI Conversation Limits:** Tracks and enforces AI conversation limits per account with backend logic and frontend warnings.
- **AI Agent Handoff & Transfer:**
    - **Manual Handoff:** Agents can transfer conversations to human teams with intent-based routing.
    - **AI Agent Transfer:** Agents can transfer conversations to other AI agents with infinite loop protection (`MAX_TRANSFER_DEPTH=3`).
    - **Silent Transfers:** Customer sees no transfer messages; operators see internal notes.
- **WhatsApp Web Integration:** Production-ready standalone Node.js microservice (`lib/whatsapp_web/`) using Baileys library for QR code-based WhatsApp Web protocol integration.
    - **Architecture:** Express HTTP API (port 3001) with ConnectionManager for session persistence, health checks, and auto-reconnect logic.
    - **Security:** Multi-layer authentication with shared secret headers (`X-Whatsapp-Secret`) and HMAC SHA256 webhook signatures (`X-Whatsapp-Signature`), using constant-time comparison (`crypto.timingSafeEqual` / `ActiveSupport::SecurityUtils.secure_compare`) to prevent timing attacks and DoS via malformed signatures.
    - **Communication:** Webhook-based event delivery (QR code, connection status, incoming messages) with signature verification; Rails HTTP client for outbound API calls (connect, disconnect, send messages).
    - **Deployment:** Configured via `WHATSAPP_WEB_SECRET` environment variable; microservice runs as separate workflow alongside Rails application.
- **URL Auto-Scraping:** `Saturn::UrlScraperService` with Nokogiri for HTML content extraction from URLs, triggered on knowledge source creation and daily sync.
    - **Security:** Implements robust security measures against SSRF/LFI/MITM, including IP filtering, DNS rebinding prevention, and strict SSL/TLS verification.
- **InstallationConfig JSONB Fix:** Migrated `InstallationConfig` model from YAML serialization to native JSONB handling for improved production stability.
- **CI/CD:** GitHub Actions for automated deployment, including dependency management, database migrations, asset compilation, and service restarts. WhatsApp Web microservice is automatically deployed and restarted via systemd service on production server.
- **Agent Enable/Disable:** Functionality to toggle AI agent status, affecting auto-response behavior.

### System Design Choices
- **Backend:** Ruby on Rails 7.1.5.2, PostgreSQL 16, Sidekiq with Redis, ActionCable, RESTful API with token authentication, Puma server.
- **Frontend:** Vue 3 with Composition API, Vite 5.4.20, Vuex, Vue Router, Tailwind CSS.
- **Development Environment:** Configured for Replit with Node.js 23.11.1, Ruby 3.2.2, PostgreSQL, and Redis, using `start_app.sh`.

## External Dependencies
- **PostgreSQL:** Primary database, managed by Replit's Neon service.
- **Redis:** Used for Sidekiq background jobs and caching.
- **OpenAI API:** Powers AI features within the Saturn AI system.
- **Vite:** Frontend build tool.
- **Tailwind CSS:** For styling the frontend.
- **Sidekiq:** Background job processor.
- **Puma:** Web server for Ruby on Rails.
- **Nix:** Manages system dependencies (PostgreSQL, openssl, pkg-config, gcc, gnumake, autoconf, redis).
- **Baileys:** Node.js library for WhatsApp Web protocol, used in the WhatsApp Web integration.