source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.0"
# Use sqlite3 as the database for Active Record
# gem "sqlite3", ">= 2.1"
gem 'pg', '~> 1.6.2'
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

gem 'net-sftp'
gem 'ed25519', '>= 1.2', '< 2.0'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem 'rspec-rails', '~> 8.0.0', require: false
  gem 'dotenv'
  gem 'vcr'
end

gem 'webmock', group: :test
