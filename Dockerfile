# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /app

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set development environment variables and enable jemalloc for reduced memory usage and latency.
ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems (rode "bundle package" no host para preencher vendor/cache e evitar rede no build)
COPY Gemfile Gemfile.lock ./
COPY vendor ./vendor/

RUN gem install bundler

# Allow lockfile update when Gemfile has new gems
RUN bundle config set --local deployment false && \
    (bundle install --local || bundle install) && \
    cp Gemfile.lock /tmp/Gemfile.lock.built

# Copy application code (Gemfile.lock do host é sobrescrito pelo do build abaixo)
COPY . .
RUN cp /tmp/Gemfile.lock.built Gemfile.lock

# Compilar CSS (Tailwind) no build para a imagem já ter application.css; no run o bin/dev pode rodar --watch para live reload
RUN mkdir -p app/assets/builds && \
    bundle exec tailwindcss -c tailwind.config.js \
      -i app/assets/stylesheets/application.css \
      -o app/assets/builds/application.css

# Entrypoint prepares the database.
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/thrust", "./bin/dev", "-b", "0.0.0.0", "-p", "3000"]
