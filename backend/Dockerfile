# This dockerfile is used to make an alpine image with ruby:2.7.6.
# This is used as base image for staging and production
FROM ruby:2.7.6-alpine as base

RUN apk update && \
    apk add bash
# Set working directory
WORKDIR backend

FROM base as gem-cache

# Copy the application
COPY Gemfile /backend
COPY Gemfile.lock /backend

# General utilities
RUN apk add --no-cache build-base git && \
    gem install bundler -v 2.3.5 && \
     bundle install

FROM base

COPY --from=gem-cache /usr/local/bundle /usr/local/bundle
COPY . /backend

# Set the entrypoint
ENTRYPOINT ["puma", "-C", "config/puma.rb"]
