source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "propshaft"
gem "pg", "~> 1.5.0"
gem "puma", ">= 5.0"
gem "jbuilder"

# Authentication & Security
gem "devise"
gem "jwt"
gem "bcrypt", "~> 3.1.7"
gem "rack-attack"

# API & Documentation
gem "rswag-api"
gem "rswag-ui"
gem "httparty"
gem "geocoder"

# Observability
gem "prometheus_exporter"

# Cache & Queue
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "thruster", require: false

group :development, :test do
  gem "dotenv-rails"
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "simplecov", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end

group :development do
  gem "rswag-specs"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
