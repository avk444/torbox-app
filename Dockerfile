# syntax=docker/dockerfile:1.4
# TorBox Manager on Hugging Face Spaces (Docker SDK)
# Builds the Next.js app inside the image, then runs ./start.sh on port 7860.

FROM oven/bun:1.3.14

USER root

# bash + sqlite3 are used by start.sh (database checkpointing)
# Uncomment ffmpeg if you need audiobook chapter extraction (adds image size)
RUN apt-get update \
 && apt-get install -y --no-install-recommends bash sqlite3 ca-certificates \
 && rm -rf /var/lib/apt/lists/*
# && apt-get install -y --no-install-recommends ffmpeg

ENV NEXT_TELEMETRY_DISABLED=1

# /data = persistent storage mount, /app = application
# Hugging Face runs containers as UID 1000, which is the built-in "bun" user
RUN mkdir -p /app /data && chown -R bun:bun /app /data

WORKDIR /app
USER bun

# Frontend dependencies (cached unless package files change)
COPY --chown=bun:bun package.json bun.lock* ./
RUN bun install --frozen-lockfile || bun install

# Backend dependencies
COPY --chown=bun:bun backend/package.json backend/bun.lock* ./backend/
RUN cd backend && (bun install --frozen-lockfile || bun install)

# Source code and production build
COPY --chown=bun:bun . .
RUN bun run build

RUN chmod +x start.sh

# Must match app_port in the README.md header (app_port: 7860)
EXPOSE 7860

CMD ["./start.sh"]
