# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

ruby RUBY_VERSION

DECIDIM_VERSION = "~> 0.24.0"

gem "decidim", DECIDIM_VERSION
# gem "decidim-consultations", DECIDIM_VERSION
# gem "decidim-initiatives", DECIDIM_VERSION

gem "decidim-antivirus", github: "mainio/decidim-module-antivirus", branch: "master"
gem "decidim-apiauth", github: "mainio/decidim-module-apiauth", branch: "master"
gem "decidim-term_customizer", github: "mainio/decidim-module-term_customizer", branch: "master"
gem "decidim-tunnistamo", github: "mainio/decidim-module-tunnistamo", branch: "develop"
gem "omniauth-tunnistamo", github: "mainio/omniauth-tunnistamo"

gem "bootsnap", "~> 1.4"

gem "puma", "~> 5.5.1"
gem "uglifier", "~> 4.1"

gem "faker", "~> 2.14"

# For the documents authorization handler
gem "henkilotunnus"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :production, :staging do
  gem "dotenv-rails", "~> 2.1", ">= 2.1.1"
  gem "rack-ssl-enforcer", "~> 0.2.9"

  gem "resque", "~> 2.0.0"
  gem "resque-scheduler", "~> 4.4"

  # Cronjobs
  gem "whenever", require: false
end

group :test do
  gem "database_cleaner"
  gem "rspec-rails"
end
