# Chatwoot - Customer Support Platform

## Overview
Chatwoot is an open-source, multi-channel customer support platform built with Ruby on Rails 7.1 and Vue.js 3. It offers AI-powered support, team collaboration, and comprehensive reporting. This project has been white-labeled as "AISATURN" and includes a custom MIT-licensed AI auto-response system called Saturn AI, developed as an alternative to enterprise solutions. The platform aims to provide a distinct, branded customer support experience ready for production deployment.

## User Preferences
- Running in development mode for easier debugging and iteration
- Using Replit's managed PostgreSQL (Neon) for database
- Single-process Puma configuration (suitable for development)

## System Architecture

### UI/UX Decisions
The platform features a completely redesigned visual identity distinct from Chatwoot, with a cohesive indigo/slate design system across all components.

**Complete Design Overhaul (October 8, 2025):**
- **Color Scheme:** Transitioned from blue (#2781F6) to indigo (#4F46E5) brand color across the entire platform
- **Palette:** Replaced all blue tones with indigo variants, implemented slate borders and backgrounds throughout
- **Theme Colors:** Updated CSS variables in `_next-colors.scss` with indigo-focused palette for light/dark modes

**Component Design System:**
- **Buttons:** rounded-md corners, shadow-sm base, lift effect on hover/focus (-translate-y-0.5 + shadow-md), consistent across all color variants (blue/ruby/amber/slate/teal)
- **Inputs:** rounded-md, white/slate backgrounds, shadow-sm, smooth 200ms transitions
- **Cards:** rounded-xl borders, shadow-md elevation, slate-200/800 outlines
- **Dialogs:** rounded-2xl, shadow-2xl, slate borders, slate-900/50 backdrop blur
- **Headers:** slate borders, white/slate backgrounds, increased height (h-14)

**Sidebar Redesign:**
- **Layout:** 240px width with gradient backgrounds (slate-50→white / slate-900→slate-950)
- **Accent System:** Left indigo accent bars on active items, indigo-50/900 backgrounds
- **Typography:** 13px semibold fonts, increased spacing (gap-3)
- **Icons:** Phosphor icon set replacing Lucide throughout

**Branding:**
- Replaced all Chatwoot branding with "AISATURN" logos and text
- Custom favicon and logo assets throughout platform

### Technical Implementations
- **Backend:** Ruby on Rails 7.1.5.2, PostgreSQL 16, Sidekiq for background jobs, ActionCable for real-time features, RESTful API with token authentication, Puma web server.
- **Frontend:** Vue 3 with Composition API, Vite 5.4.20 for asset building, Vuex for state management, Vue Router, and Tailwind CSS for styling. Vite compiles assets on-demand for Rails views.
- **Saturn AI (MIT-Licensed Auto-Response System):**
    - **Architecture:** Uses `saturn_*` database tables (`saturn_agent_profiles`, `saturn_knowledge_sources`, `saturn_inbox_connections`), dedicated backend models, and services like `Saturn::Orchestrator` (multi-turn conversation) and `Saturn::LlmService` (OpenAI integration).
    - **Features:** Full CRUD for agents, knowledge sources (Text/Document, URL, FAQ), and inbox connections. Includes UI for agent management, knowledge base configuration, and connecting agents to inboxes.
    - **Auto-Response Mechanism:** Event-driven system using `SaturnListener` and `Saturn::AutoRespondJob` to provide AI-powered responses to incoming messages in connected inboxes, leveraging a knowledge base for relevant information.
- **CI/CD:** Automated deployment pipeline via GitHub Actions to Digital Ocean, using SSH key authentication.
- **Configuration:** Optimized `start_app.sh` script for workflow entry, `config/puma.rb` for server, `vite.config.ts` for frontend, and `.env` for environment variables.

### Feature Specifications
- **AISATURN Branding:** Full white-label branding implemented.
- **Saturn AI:** Provides AI-powered auto-responses using OpenAI, with distinct architectural components and UI for managing agents, knowledge sources, and inbox connections.
- **Multi-channel Communication:** Core Chatwoot functionality for managing customer interactions across various channels.
- **Team Collaboration:** Tools for agents to collaborate on customer support tickets.
- **Reporting:** Comprehensive features for tracking and analyzing support performance.

## External Dependencies
- **PostgreSQL 16:** Database, provided via Replit's Neon service. Requires `pgvector` extension for AI embeddings.
- **Redis:** Used for Sidekiq background jobs and caching.
- **OpenAI:** Integrated for the Saturn AI auto-response system's LLM capabilities. Requires an OpenAI API key.
- **Node.js 23.11.1 & pnpm 10.2.0:** For frontend development and asset compilation.
- **Ruby 3.2.2:** Core backend language runtime.
- **Vite 5.4.20:** Frontend build tool, integrated via `vite_rails` gem.
- **Tailwind CSS:** For styling the frontend.
- **Puma 6.4.3:** Web server for the Rails application.
- **Sidekiq 7.3.1:** Background job processor.