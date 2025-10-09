# Chatwoot - Customer Support Platform

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