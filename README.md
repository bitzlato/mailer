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

2. Configure barong database name (default - barong_development)
```
export DATABASE_NAME=barong_database
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

# Environment variables
<details>
  <summary>Variables list</summary>

- **DATABASE_NAME** - *url of redis server with port (example: 'redis://localhost:6379/1')*
- **BUGSNAG_API_KEY** - *Notifier API key from [bugsnag](https://www.bugsnag.com) (example: QWE1234567890)*
- **MAILER_EVENT_API_RABBITMQ_URL** - *(example: amqp://guest:guest@localhost:5672)*
- **MAILER_DEFAULT_LANGUAGE** - *default language for emails, default en*
- **MAILER_SENDER_EMAIL** - *FROM field email, default noreply@barong.io*
- **MAILER_SENDER_NAME** - *FROM field name, default Barong*
- **MAILER_SMTP_PASSWORD** - *smtp setting password*
- **MAILER_SMTP_PORT** - *smtp setting port*
- **MAILER_SMTP_HOST** - *smtp setting host*
- **MAILER_SMTP_USER** - *smtp setting user*
- **MAILER_SMTP_LOGO_LINK** - *link to logo in emails*
- **MAILER_SMTP_SIGNATURE** - *signature in footer, can be html code*

