FROM rust:1.98.1@sha256:a8a5f0a1e5fe7dfe1d352591e4a1c7dd2c08fd70475cae872cf3458ba0df0546 AS build
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
