#!/bin/bash

echo "Starting Chatwoot Production..."
echo "================================"

# Export database environment variables (from Replit Secrets)
export POSTGRES_HOST=$PGHOST
export POSTGRES_USERNAME=$PGUSER
export POSTGRES_PASSWORD=$PGPASSWORD
export POSTGRES_DATABASE=$PGDATABASE
export POSTGRES_PORT=$PGPORT
export REDIS_URL=${REDIS_URL:-redis://localhost:6379}
export RAILS_ENV=production
export RAILS_MAX_THREADS=5
export PORT=5000

# Use Replit's SECRET_KEY_BASE if available, otherwise generate
if [ -z "$SECRET_KEY_BASE" ]; then
    if [ ! -f .secret_key_base_production ]; then
        echo "Generating new production SECRET_KEY_BASE..."
        openssl rand -hex 64 > .secret_key_base_production
    fi
    export SECRET_KEY_BASE=$(cat .secret_key_base_production)
fi

echo "Rails environment: $RAILS_ENV"
echo "Database: $POSTGRES_DATABASE"
echo "Redis: $REDIS_URL"
echo ""

# Ensure Redis is running (for local development-style deployments)
if ! pgrep redis-server > /dev/null; then
    echo "Starting Redis server..."
    redis-server --daemonize yes --port 6379
fi

# Start Sidekiq in background
echo "Starting Sidekiq background worker..."
bundle exec sidekiq -C config/sidekiq.yml > log/sidekiq.log 2>&1 &
SIDEKIQ_PID=$!
echo "Sidekiq started (PID: $SIDEKIQ_PID)"

# Wait a moment for Sidekiq to initialize
sleep 2

# Start Puma
echo "Starting Puma web server on port 5000..."
exec bundle exec puma -C config/puma.rb -p 5000
