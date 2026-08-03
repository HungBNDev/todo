# syntax=docker/dockerfile:1
ARG RUBY_VERSION=4.0.3
FROM docker.io/library/ruby:$RUBY_VERSION-alpine AS base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle"

# Install all runtime packages in a single layer
RUN apk add --no-cache curl vips postgresql-client nodejs npm yarn bash tzdata openssh-client

# Builder stage
FROM base AS build

# Combine package installation and SSH setup into a single layer
RUN apk add --no-cache git build-base postgresql-dev pkgconfig yaml-dev

# Install gems
COPY Gemfile Gemfile.lock ./
RUN --mount=type=ssh bundle install --jobs 4

# Install JS dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile

# Final stage
FROM base

# Copy gems and application files
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
