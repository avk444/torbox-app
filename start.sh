#!/bin/bash

APP_DIR="/app"
REAL_PERSISTENT_BUCKET="/data"

echo "Initializing Direct Persistent Disk Binding..."

# 1. Ensure the permanent cloud storage directory structure exists on the disk
mkdir -p "$REAL_PERSISTENT_BUCKET/users"
if [ ! -f "$REAL_PERSISTENT_BUCKET/master.db" ]; then
    touch "$REAL_PERSISTENT_BUCKET/master.db"
fi

# 2. Grant full read/write permissions to the persistent volume
chmod -R 777 "$REAL_PERSISTENT_BUCKET" 2>/dev/null || true

# 3. List every possible directory path where the upstream app might look for databases
PARENTS=(
    "$APP_DIR"
    "$APP_DIR/data"
    "$APP_DIR/backend"
    "$APP_DIR/backend/data"
    "$APP_DIR/backend/src"
    "$APP_DIR/backend/src/data"
    "$APP_DIR/backend/src/database"
)

echo "Linking all application paths directly to persistent cloud storage..."
for p in "${PARENTS[@]}"; do
    mkdir -p "$p" 2>/dev/null || true
    
    # Remove any ephemeral directories or empty dummy files created during container build
    rm -rf "$p/users" "$p/master.db"* 2>/dev/null || true
    
    # Create direct symbolic tunnels to the persistent cloud disk
    ln -s "$REAL_PERSISTENT_BUCKET/users" "$p/users"
    ln -s "$REAL_PERSISTENT_BUCKET/master.db" "$p/master.db"
done

# ==========================================================
# PHASE 2: CLASSIC PRODUCTION LAUNCH
# ==========================================================
echo "Starting Backend Engine..."
cd "$APP_DIR/backend"
PORT=3001 bun start &

cd "$APP_DIR"
echo "Starting Production Frontend Interface..."
PORT=7860 BACKEND_URL=http://127.0.0.1:3001 BACKEND_DISABLED=false bun start
