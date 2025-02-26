FROM elixir:1.15-alpine AS build

ENV MIX_ENV=prod

RUN apk update && \
    apk add --no-cache build-base nodejs npm git

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config config

RUN mix deps.get --only prod
RUN mix deps.compile

COPY assets assets
RUN npm install --prefix assets

COPY . .

RUN mix deps.get && mix compile && mix phx.digest && mix release


FROM alpine:3.17 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs ffmpeg

WORKDIR /app

COPY --from=build /app/_build/prod/rel/vantage ./

EXPOSE 4000


CMD ["bin/vantage", "start"]