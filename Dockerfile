# Multi-stage Dockerfile for Auto-Trader

# Stage 1: Build Frontend Assets
FROM node:20-bookworm-slim AS frontend-builder
WORKDIR /app/frontend
RUN npm install -g pnpm
COPY frontend/package.json frontend/pnpm-lock.yaml* ./
RUN pnpm install
COPY frontend/ ./
RUN pnpm run build

# Stage 2: Build Rust Backend Server
FROM rust:1.82-bookworm AS rust-builder
WORKDIR /app
RUN apt-get update && apt-get install -y pkg-config libssl-dev build-essential && rm -rf /var/lib/apt/lists/*
COPY Cargo.toml Cargo.lock ./
COPY shared_domain ./shared_domain
COPY backend ./backend
RUN cargo build --release -p server

# Stage 3: Production Runtime
FROM node:20-bookworm-slim AS runner
WORKDIR /app

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    bash \
    sqlite3 \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Structure directory layout to match runtime relative path resolutions
COPY --from=rust-builder /app/target/release/server /app/backend/server
COPY --from=frontend-builder /app/frontend/dist /app/frontend/dist
COPY kotak-bridge /app/kotak-bridge
RUN cd /app/kotak-bridge && npm install --omit=dev

WORKDIR /app/backend

ENV PORT=8080
ENV RUST_LOG=info
ENV APP_ENV=production

EXPOSE 8080

CMD ["./server"]
