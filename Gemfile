# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "~> 0.27.9"

gem "decidim", DECIDIM_VERSION

gem "decidim-antivirus", github: "mainio/decidim-module-antivirus", branch: "release/0.27-stable"
gem "decidim-apiext", github: "City-of-Turku/decidim-module-apiext", branch: "release/0.27-stable"
gem "decidim-apifiles", github: "mainio/decidim-module-apifiles", branch: "release/0.27-stable"
gem "decidim-privacy", github: "mainio/decidim-module-privacy", branch: "release/0.27-stable"
gem "decidim-term_customizer", github: "mainio/decidim-module-term_customizer", branch: "release/0.27-stable"
gem "decidim-tunnistamo", github: "mainio/decidim-module-tunnistamo", branch: "main"
gem "omniauth-tunnistamo", github: "mainio/omniauth-tunnistamo", branch: "main"

# Maintenance patches required for 0.27
gem "decidim-patches", github: "mainio/decidim-module-patches"

gem "bootsnap", "~> 1.18"

gem "puma", "~> 5.6.8"

gem "faker", "~> 2.19"

# For the documents authorization handler
gem "henkilotunnus"

group :development, :test do
  gem "byebug", "~> 11.1", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.8"
  gem "rubocop-faker"
  gem "spring", "~> 4.1"
  gem "spring-watcher-listen", "~> 2.1"
  gem "web-console", "~> 4.2"
end

group :production, :staging do
  gem "dotenv-rails", "~> 3.0"
  gem "rack-ssl-enforcer", "~> 0.2.9"

  gem "resque", "~> 2.7.0"
  gem "resque-scheduler", "~> 4.11"

  # Cronjobs
  gem "whenever", require: false
end

group :test do
  gem "database_cleaner"
  gem "rspec-rails"
end
