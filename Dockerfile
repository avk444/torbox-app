FROM oven/bun:1

USER root
RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data && chmod 777 /data

WORKDIR /home/bun/app
COPY --chown=bun:bun . .

RUN bun install
RUN bun run build

WORKDIR /home/bun/app/backend
RUN bun install

WORKDIR /home/bun/app
RUN chmod +x start.sh

USER bun
EXPOSE 7860
CMD ["./start.sh"]
