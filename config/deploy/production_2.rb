# frozen_string_literal: true

set :stage, :production
set :rails_env, :production
fetch(:default_env)[:rails_env] = :production
set :application, 'mailer_2'
set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:application)}" }

server ENV.fetch('PRODUCTION_SERVER'),
       user: 'app',
       port: '22',
       roles: %w[app mailer].freeze,
       ssh_options: { forward_agent: true }
