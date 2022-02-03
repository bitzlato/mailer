# frozen_string_literal: true

require 'mailer/app'

Mailer::App.define do |config|
  config.set(:default_language, 'en')
  config.set(:event_api_rabbitmq_url, 'amqp://guest:guest@localhost:5672')
  config.set(:sender_email, 'noreply@barong.io')
  config.set(:sender_name, 'Barong')
  config.set(:smtp_password, '')
  config.set(:smtp_port, 1025)
  config.set(:smtp_host, 'localhost')
  config.set(:smtp_user, '')
  config.set(:smtp_logo_link, 'https://storage.cloud.google.com/public_peatio/logo.png')
end

ActionMailer::Base.smtp_settings = {
  address: Mailer::App.config.smtp_host,
  port: Mailer::App.config.smtp_port,
  user_name: Mailer::App.config.smtp_user,
  password: Mailer::App.config.smtp_password
}.delete_if { |k,v| v.blank? }


