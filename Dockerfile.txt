FROM oven/bun:1

USER root
# Install bash and sqlite3 utilities for database checkpoint consolidation
RUN apt-get update && apt-get install -y bash sqlite3 && rm -rf /var/lib/apt/lists/*

# Pre-create data mount and application zones
RUN mkdir -p /data && chmod 777 /data
RUN mkdir -p /app && chmod 777 /app

WORKDIR /app
COPY . .

RUN bun install

WORKDIR /app/backend
RUN bun install

WORKDIR /app
RUN chmod +x start.sh

USER root
EXPOSE 7860

CMD ["./start.sh"]
