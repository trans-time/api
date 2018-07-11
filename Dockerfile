# Alias this container as builder:
FROM bitwalker/alpine-elixir-phoenix as builder

ENV MIX_ENV=prod

COPY . .

RUN mix do deps.get, deps.compile

RUN MIX_ENV=prod mix phx.digest
RUN mix release --env=prod --verbose

RUN APP_NAME="api" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export



FROM alpine:3.6

RUN apk upgrade --no-cache && \
    apk add --no-cache bash openssl && \
    apk add --no-cache file && \
    apk add --no-cache imagemagick
    # we need bash and openssl for Phoenix

EXPOSE 4000

ENV PORT=4000 \
    MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    SHELL=/bin/bash

COPY --from=builder /export/ .

RUN chown -R root ./releases

USER root

CMD ["/bin/api", "foreground"]
