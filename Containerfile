FROM lukemathwalker/cargo-chef:latest-rust-slim as chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release --bin app

FROM scratch AS runtime
WORKDIR /app
COPY --from=builder /app/config.toml /usr/local/bin/config.toml
COPY --from=builder /app/app /usr/local/bin/app
EXPOSE 28019
ENTRYPOINT ["/bin/app"]
