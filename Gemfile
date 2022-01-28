source 'https://rubygems.org'
git_source(:github) { |repo| 'https://github.com/#{repo}.git' }

ruby '2.7.5'

gem 'rails', '~> 7.0.1'
gem 'sprockets-rails'
gem 'gli', '~> 2.19.0'
gem 'pg', '~> 1.2'
gem 'bunny'
gem 'dotenv'
gem 'jwt', '~> 2.3.0'
gem 'jwt-multisig', '~> 1.0', '>= 1.0.4'
gem 'semver2', '~> 3.4'
gem 'bugsnag'


group :development, :test do
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'rubocop'
  gem 'rspec-rails'
end

group :development do
  gem 'spring'
  gem 'foreman'
  gem 'pry-rails'
end

