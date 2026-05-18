FROM oven/bun:1

USER root
RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

# Pre-create data directory for the storage bucket mount
RUN mkdir -p /data && chmod 777 /data

WORKDIR /home/bun/app

# Copy files and set correct permissions for non-root user
COPY --chown=bun:bun . .

# ==========================================
# LOW-MEMORY BUILD CONSTRAINTS FOR NEXT.JS
# ==========================================
ENV NEXT_TELEMETRY_DISABLED=1
ENV NEXT_DISABLE_SOURCEMAPS=1
ENV GENERATE_SOURCEMAP=false
ENV NODE_ENV=production

# Clear out any bloated caching folders before building
RUN rm -rf node_modules backend/node_modules .next

# Install dependencies cleanly
RUN bun install

# Run production compilation with minimized memory profiles
RUN bun run build

# Navigate to backend engine and initialize dependencies cleanly
WORKDIR /home/bun/app/backend
RUN rm -rf node_modules
RUN bun install

WORKDIR /home/bun/app
RUN chmod +x start.sh

USER bun
EXPOSE 7860

CMD ["./start.sh"]
