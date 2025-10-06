#!/bin/bash

echo "Starting Chatwoot Application..."
echo "================================"

# Kill any existing process on port 5000
echo "Checking for existing process on port 5000..."
fuser -k 5000/tcp 2>/dev/null || true
sleep 2

# Ensure Redis is running
if ! pgrep redis-server > /dev/null; then
    echo "Starting Redis server..."
    redis-server --daemonize yes --port 6379
fi

# Export database environment variables
export POSTGRES_HOST=$PGHOST
export POSTGRES_USERNAME=$PGUSER
export POSTGRES_PASSWORD=$PGPASSWORD
export POSTGRES_DATABASE=$PGDATABASE
export POSTGRES_PORT=$PGPORT
export REDIS_URL=redis://localhost:6379
export RAILS_ENV=development
export RAILS_MAX_THREADS=5
export FRONTEND_URL=http://localhost:5000
export PORT=5000

# Generate or load persistent SECRET_KEY_BASE
if [ ! -f .secret_key_base ]; then
    echo "Generating new SECRET_KEY_BASE..."
    openssl rand -hex 64 > .secret_key_base
fi
export SECRET_KEY_BASE=$(cat .secret_key_base)
export DISABLE_MINI_PROFILER=true

echo "Rails environment: $RAILS_ENV"
echo "Database: $POSTGRES_DATABASE"  
echo "Redis: $REDIS_URL"
echo "Frontend URL: $FRONTEND_URL"
echo ""
echo "Starting Sidekiq background worker..."
bundle exec sidekiq -C config/sidekiq.yml > log/sidekiq.log 2>&1 &
SIDEKIQ_PID=$!
echo "Sidekiq started (PID: $SIDEKIQ_PID)"
echo ""
echo "Starting Rails server on port 5000..."
echo ""

# Cleanup function for graceful shutdown
cleanup() {
    echo ""
    echo "Shutting down..."
    kill $SIDEKIQ_PID 2>/dev/null
    exit 0
}
trap cleanup SIGTERM SIGINT

# Start Rails with puma
exec bundle exec puma -C config/puma.rb
