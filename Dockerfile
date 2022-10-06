FROM ruby:2.7.5-alpine
RUN apk --update add git build-base tzdata postgresql-dev postgresql-client libxslt-dev libxml2-dev
ENV INSTALL_PATH /mailer
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH
COPY Gemfile Gemfile.lock ./
ARG RAILS_ENV
ENV RACK_ENV=$RAILS_ENV
RUN gem install bundler
RUN if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test deploy; else bundle install; fi
COPY . ./
