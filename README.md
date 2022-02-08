[![Ruby](https://github.com/bitzlato/mailer/actions/workflows/ruby.yml/badge.svg)](https://github.com/bitzlato/mailer/actions/workflows/ruby.yml)

# Mailer
Event based mailing system: support multi-language, secured by cryptographic signatures


# Development

Prerequisites:
- Ruby version: `2.7.5`
- Bundler preinstalled
- Connection to Barong database
- Configured RabbitMQ

1. Install RubyGems dependencies
```
bundle install
```

2. Configure barong and bitzlato databases (default barong_development and bitzlato_development)
```
export DATABASE_NAME=barong_development
export BITZLATO_DATABASE_NAME=bitzlato_development

```

3. Configure RabbitMQ connection url (default - amqp://guest:guest@localhost:567)
```
export MAILER_EVENT_API_RABBITMQ_URL=amqp://guest:guest@localhost:5672
```

4. Start demon
```
bundle exec ./bin/mailer run
```

5. For preview emails use [mailcatcher]([https://mailcatcher.me/)
```
gem install mailcatcher
mailcatcher
```
and open  http://127.0.0.1:1080/

6. Running tests
```
RAILS_ENV=test rake db:drop db:create db:schema:load
bundle exec rake
```

# Environment variables
<details>
  <summary>Variables list</summary>

- **PEATIO_JWT_PUBLIC_KEY** - peatio jwt public key
- **BARONG_JWT_PUBLIC_KEY**  - barong jwt public key
- **DATABASE_URL** - *url for database connection in stage and production environment (example: 'postgresql://127.0.0.1:5432/barong')*
- **BITZLATO_DATABASE_URL** - *url for bitzlato database connection (example: 'postgresql://127.0.0.1:5432/bitzlato')*
- **DATABASE_NAME** - *name of database, used in development and test environment (example: 'barong_development')*
- **BUGSNAG_API_KEY** - *Notifier API key from [bugsnag](https://www.bugsnag.com) (example: QWE1234567890)*
- **MAILER_EVENT_API_RABBITMQ_URL** - *(example: amqp://guest:guest@localhost:5672)*
- **MAILER_DEFAULT_LANGUAGE** - *default language for emails, default en*
- **MAILER_SENDER_EMAIL** - *FROM field email, default noreply@barong.io*
- **MAILER_SENDER_NAME** - *FROM field name, default Barong*
- **MAILER_SMTP_PASSWORD** - *smtp setting password*
- **MAILER_SMTP_PORT** - *smtp setting port*
- **MAILER_SMTP_HOST** - *smtp setting host*
- **MAILER_SMTP_USER** - *smtp setting user*

