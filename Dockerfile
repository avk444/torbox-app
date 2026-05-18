FROM oven/bun:1

USER root
RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

# Pre-create data directory for the storage bucket mount
RUN mkdir -p /data && chmod 777 /data

WORKDIR /home/bun/app

# Copy the pre-compiled files (.next tracking folder is included automatically)
COPY --chown=bun:bun . .

# Run an installation to wire up dependencies (very light on memory)
RUN bun install

WORKDIR /home/bun/app/backend
RUN bun install

WORKDIR /home/bun/app
RUN chmod +x start.sh

USER bun
EXPOSE 7860

CMD ["./start.sh"]
