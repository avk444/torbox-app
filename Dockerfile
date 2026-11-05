# syntax=docker/dockerfile:1.4
# TorBox Manager on Hugging Face Spaces (Docker SDK)
# The Next.js app is compiled on GitHub Actions and the .next folder is
# pushed to this Space, so no build runs here (the HF builder runs out of RAM).

FROM oven/bun:1.3.14

USER root

# bash + sqlite3 are used by start.sh (database checkpointing)
RUN apt-get update \
 && apt-get install -y --no-install-recommends bash sqlite3 ca-certificates \
 && rm -rf /var/lib/apt/lists/*

ENV NEXT_TELEMETRY_DISABLED=1

# /data = persistent storage mount, /app = application
# Hugging Face runs containers as UID 1000, which is the built-in "bun" user
RUN mkdir -p /app /data && chown -R bun:bun /app /data

WORKDIR /app
USER bun

# Frontend dependencies
COPY --chown=bun:bun package.json bun.lock* ./
RUN bun install --frozen-lockfile || bun install

# Backend dependencies
COPY --chown=bun:bun backend/package.json backend/bun.lock* ./backend/
RUN cd backend && (bun install --frozen-lockfile || bun install)

# Source code + prebuilt .next folder pushed by the GitHub workflow
COPY --chown=bun:bun . .

# Fail early with a clear message if the prebuilt output is missing
RUN test -d .next || (echo "ERROR: .next folder missing. The GitHub workflow must push it to this Space." && exit 1)

RUN chmod +x start.sh

# Must match app_port in the README.md header (app_port: 7860)
EXPOSE 7860

CMD ["./start.sh"]
