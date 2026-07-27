FROM rust:1.97.1@sha256:1bcff4befb740599103a2c7cb51058e14479b2e35e3a34a3f0dc4ede09927488 AS build
WORKDIR /app

COPY Cargo.toml Cargo.lock ./
COPY config ./config
COPY src ./src

RUN cargo build --release \
    && cp target/release/hashavatar-website /usr/local/bin/hashavatar-website \
    && rm -rf target /usr/local/cargo/registry /usr/local/cargo/git

FROM cgr.dev/chainguard/wolfi-base:latest@sha256:02dab76bd852a70556b5b2002195c8a5fdab77d323c433bf6642aab080489795
RUN addgroup -S appuser \
    && adduser -S -D -H -u 10001 -G appuser appuser
WORKDIR /app

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /usr/local/bin/hashavatar-website /usr/local/bin/hashavatar-website

ENV PORT=8080
ENV PUBLIC_WEBSITE_HOST=0.0.0.0
EXPOSE 8080
USER appuser
CMD ["hashavatar-website"]
