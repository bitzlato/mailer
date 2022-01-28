# frozen_string_literal: true

set :stage, :production
set :rails_env, :production
fetch(:default_env)[:rails_env] = :production

server ENV.fetch('PRODUCION_SERVER'),
       user: 'app',
       port: '22',
       roles: %w[mailer].freeze,
       ssh_options: { forward_agent: true }
