# ---------- Build stage ----------
FROM rust:1.75 AS builder

WORKDIR /app

COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release

COPY src ./src
RUN cargo build --release

# ---------- Runtime stage ----------
FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Replace `api` if your binary name differs
COPY --from=builder /app/target/release/api /app/api

EXPOSE 8080

ENV APP_PORT=8080
CMD ["/app/api"]
