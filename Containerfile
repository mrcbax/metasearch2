FROM lukemathwalker/cargo-chef:latest-rust-slim as chef
WORKDIR /app

FROM chef AS planner
COPY ./Cargo.toml ./config.toml ./Cargo.lock ./
COPY ./src ./src
RUN cargo chef prepare

FROM chef AS builder
COPY --from=planner /app/recipe.json .
RUN cargo chef cook --release
COPY . .
RUN cargo build --release
RUN mv ./target/release/metasearch2 ./app

FROM scratch AS runtime
WORKDIR /app
COPY --from=builder /app/app /bin/
COPY --from=builder /app/config.toml /bin/
EXPOSE 28019
ENTRYPOINT ["/usr/local/bin/app"]
