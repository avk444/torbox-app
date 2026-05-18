#!/bin/bash

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "$APP_DIR/backend/users"
mkdir -p /data/users

if [ -f "/data/master.db" ]; then
    cp /data/master.db "$APP_DIR/backend/master.db"
fi

if [ "$(ls -A /data/users 2>/dev/null)" ]; then
    cp -r /data/users/* "$APP_DIR/backend/users/" 2>/dev/null
fi

(
    while true; do
        sleep 30
        if [ -f "$APP_DIR/backend/master.db" ]; then
            cp "$APP_DIR/backend/master.db" /data/master.db
        fi
        if [ "$(ls -A "$APP_DIR/backend/users" 2>/dev/null)" ]; then
            cp -r "$APP_DIR/backend/users/"* /data/users/ 2>/dev/null
        fi
    done
) &

echo "Starting Backend Engine..."
cd "$APP_DIR/backend"
PORT=3001 bun start &

sleep 5

echo "Starting Frontend Interface..."
cd "$APP_DIR"
PORT=7860 BACKEND_URL=http://127.0.0.1:3001 BACKEND_DISABLED=false bun start
