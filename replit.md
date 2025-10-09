# Chatwoot - Customer Support Platform

## Recent Changes (October 9, 2025)

### ⚙️ AI Agent Status Toggle - COMPLETE

**Agent Enable/Disable Functionality:**
- ✅ Database: `enabled` column (boolean, default true) added to saturn_agent_profiles
- ✅ Frontend: Toggle switch in AgentCard for activating/deactivating agents
- ✅ Backend: Chat endpoint and AutoRespondJob check enabled status before responding
- ✅ API: Returns enabled field in agent responses
- ✅ Model: Updated scope and push_event_data to use enabled instead of active
- ✅ Migration: Legacy `active` column removed, Rails migration added for tracking
- ✅ Turkish i18n: Full translation support for status toggle

**Behavior:**
- Disabled agents skip auto-responding in AutoRespondJob
- Chat endpoint returns error when agent is disabled
- Toggle updates agent status in real-time with user feedback

### 🚀 AI Agent Handoff & Transfer Features - COMPLETE

**Manual Operator Handoff with Intent-Based Routing:**
- ✅ Database: handoff_enabled, handoff_team_id, intent_routing_enabled, intent_team_mappings columns
- ✅ Backend: HandoffAgent tool transfers conversation to human team
- ✅ Conversation state: Sets status to pending and assigns to team
- ✅ Frontend: Dedicated HandoffDialog accessible via agent card button (removed from edit dialog)
- ✅ Intent-Based Routing: Map customer intents to specific teams for smart routing
- ✅ Default Team: Fallback team when no intent matches or routing disabled
- ✅ Dynamic Intent Mapping: Add/remove intent→team mappings with live UI
- ✅ Turkish i18n: Full translation support for all handoff features

**AI-to-AI Agent Transfer:**
- ✅ Database: transfer_enabled, transfer_agent_id columns in saturn_agent_profiles
- ✅ Backend: AgentTransfer tool switches conversation to different AI agent
- ✅ Conversation persistence: current_saturn_agent_id stored in custom_attributes
- ✅ Infinite loop protection: MAX_TRANSFER_DEPTH=3 prevents cyclic transfers
- ✅ Depth tracking: transfer_depth persists across messages via SaturnListener
- ✅ Frontend: Toggle and agent selector in edit dialog
- ✅ Turkish i18n: Full translation support

**Recursion Safety:**
- ✅ Cross-message depth persistence: Prevents A→B→A loops across multiple messages
- ✅ Error handling: User-friendly message when depth limit exceeded
- ✅ Logging: Full audit trail with depth tracking

**UI Organization:**
- Handoff settings moved to dedicated dialog (button on agent card)
- Agent transfer settings remain in edit dialog
- Cleaner separation of concerns for better UX

### 🔧 Critical Bug Fixes & Production Deployment Fix

**InstallationConfig JSONB Fix - Production Ready:**
- ✅ Fixed TypeError in production: YAML serialization removed from InstallationConfig model
- ✅ Native JSONB handling implemented with proper nil guards
- ✅ **Production database cleaned:** 84 old YAML configs removed via direct PostgreSQL
- ✅ **Deployment workflow updated:** Automatic YAML cleanup after every migration
- ✅ **Future-proof:** Every deployment now auto-cleans old YAML configs before restart
- Files: `app/models/installation_config.rb`, `.github/workflows/deploy.yml`

**AI Conversation Limits - Restored:**
- ✅ Database columns: ai_conversation_limit, ai_conversation_count, ai_limit_reset_at
- ✅ Backend logic: Account model methods (increment, reset, check limit)
- ✅ AutoRespondJob: Limit checking before generating responses
- ✅ API: Limit info exposed in account endpoint
- ✅ Frontend: Warning banner on Saturn AI page (yellow at 20%, red at 0%)
- ✅ Turkish i18n: Limit warning messages

**Menu Cleanup:**
- ❌ Removed: Inbox (standalone), Live Chat, SMS campaigns, Portals/Help Center, Integrations
- ✅ Updated: All icons changed from Lucide to Phosphor (ph-thin) for consistency
- ✅ Streamlined: Conversations, Saturn AI, Contacts, Reports, Settings, WhatsApp campaigns

### 🔐 URL Auto-Scraping with Enterprise Security - COMPLETE

**Automatic Web Content Scraping:**
- ✅ Service: Saturn::UrlScraperService with Nokogiri for HTML parsing and content extraction
- ✅ Auto-scraping: ScrapeUrlJob triggered on URL knowledge source creation
- ✅ Daily refresh: DailyUrlSyncJob scheduled at 01:00 UTC (04:00 Turkey time) via Sidekiq-cron
- ✅ Metadata tracking: scraping_status (success/failed), scraping_error, last_scraped_at
- ✅ Frontend: Real-time scraping status badges (green checkmark, red failed, blue loading)
- ✅ URL Limit: Configurable max URL sources per account via InstallationConfig (default: 100)

**Production-Grade Security (SSRF/LFI/MITM Protection):**
- ✅ DNS resolution: Single Resolv.getaddresses call, validated IP reused for connection
- ✅ IP filtering: Blocks loopback (127.0.0.0/8, ::1), private (RFC1918, fc00::/7), link-local (169.254.0.0/16, fe80::/10)
- ✅ DNS rebinding prevention: Net::HTTP connects to validated IP directly, no re-resolution
- ✅ SSL/TLS verification: VERIFY_PEER with CA chain + hostname validation on leaf certificate
- ✅ Self-signed cert rejection: preverify_ok && verify_certificate_identity ensures valid CA
- ✅ SNI support: http.hostname set for proper certificate presentation (Ruby 3.0+)
- Files: `app/services/saturn/url_scraper_service.rb`, `app/jobs/saturn/scrape_url_job.rb`, `app/jobs/saturn/daily_url_sync_job.rb`

## Overview
Chatwoot is an open-source customer support platform offering multi-channel communication, AI-powered support agents, team collaboration, and reporting. It is a Ruby on Rails 7.1 + Vue.js 3 application, rebranded as AISATURN, focusing on AI-driven customer support solutions. The project aims to provide a comprehensive, white-label platform for businesses to manage customer interactions efficiently.

## User Preferences
- Running in development mode for easier debugging and iteration
- Using Replit's managed PostgreSQL (Neon) for database
- Single-process Puma configuration (suitable for development)

## System Architecture

### UI/UX Decisions
- **Branding:** Full white-label branding with AISATURN replacing all Chatwoot branding, including logos, favicons, and text across the Super Admin Console, Login page, and Dashboard Sidebar.
- **Iconography:** All icons updated from Lucide to Phosphor (ph-thin) for consistency.
- **Menu Structure:** Streamlined sidebar menu with key features: Conversations, Saturn AI, Contacts, Reports, Settings, WhatsApp campaigns. Unused items like standalone Inbox, Live Chat, SMS campaigns, Portals/Help Center, and Integrations have been removed.

### Technical Implementations
- **AI Auto-Response System (Saturn AI):** MIT-licensed system for AI-powered automatic responses using OpenAI integration.
    - **Database:** `saturn_agent_profiles`, `saturn_knowledge_sources`, `saturn_inbox_connections`.
    - **Models:** `Saturn::AgentProfile`, `Saturn::KnowledgeSource`, `Saturn::InboxConnection`.
    - **Services:** `Saturn::Orchestrator` for multi-turn conversations, `Saturn::LlmService` for OpenAI integration.
    - **Auto-Response Logic:** Event-driven architecture using `SaturnListener` and `Saturn::AutoRespondJob` for real-time AI responses, including idempotency checks and robust sender selection. Knowledge is integrated via `search_knowledge_base` tool.
- **AI Conversation Limits:** Implemented backend logic and frontend UI for tracking and displaying AI conversation limits per account.
- **InstallationConfig JSONB Fix:** Migrated from YAML serialization to native JSONB handling with `nil` guards for `InstallationConfig` model.
- **CI/CD:** GitHub Actions for automated deployment to Digital Ocean.

### Feature Specifications
- **Agent Management:** Card-based list with dialog-based CRUD operations for AI agents.
- **Knowledge Sources:** CRUD for documents, URLs, and FAQs, with agent-specific knowledge bases.
- **Inbox Connections:** Ability to connect AI agents to specific inboxes for automated responses.
- **Handoff & Transfer:**
  - **Manual Handoff:** AI agents can transfer conversations to human teams when configured
  - **AI Agent Transfer:** AI agents can transfer conversations to other AI agents with different expertise
  - **Infinite Loop Protection:** MAX_TRANSFER_DEPTH=3 prevents cyclic transfers (A→B→A)
  - **Depth Persistence:** Transfer depth tracked across messages via conversation.custom_attributes
  - **Error Handling:** User-friendly messages when limits exceeded

### System Design Choices
- **Backend:** Ruby on Rails 7.1.5.2, PostgreSQL 16, Sidekiq with Redis for background jobs, ActionCable for real-time features, RESTful API with token authentication, Puma server.
- **Frontend:** Vue 3 with Composition API, Vite 5.4.20, Vuex for state management, Vue Router, Tailwind CSS. Vite compiles assets on-demand for Rails views.
- **Development Environment:** Configured for Replit with Node.js 23.11.1, Ruby 3.2.2, PostgreSQL, and Redis. Uses `start_app.sh` for streamlined workflow.

## External Dependencies
- **PostgreSQL:** Used as the primary database, integrated via Replit's Neon service.
- **Redis:** Used for Sidekiq background jobs and caching.
- **OpenAI API:** Integrated for AI-powered features in the Saturn AI system, requiring an API key.
- **Vite:** Frontend build tool.
- **Tailwind CSS:** For styling the frontend.
- **Sidekiq:** Background job processor.
- **Puma:** Web server for Ruby on Rails.
- **Nix:** Used for managing system dependencies (PostgreSQL, openssl, pkg-config, gcc, gnumake, autoconf, redis).