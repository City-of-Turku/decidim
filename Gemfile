# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "mainio/decidim", branch: "accessibility/202003" }

gem "decidim", DECIDIM_VERSION
# gem "decidim-consultations", DECIDIM_VERSION
# gem "decidim-initiatives", DECIDIM_VERSION

gem "decidim-tunnistamo", github: "mainio/decidim-module-tunnistamo"
gem "omniauth-tunnistamo", github: "mainio/omniauth-tunnistamo"

gem "bootsnap", "~> 1.3"

gem "puma", "~> 4.3.3"
gem "uglifier", "~> 4.1"

gem "faker", "~> 1.9"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", "0.22.0.dev"
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :production, :staging do
  gem "rack-ssl-enforcer", "~> 0.2.9"
  gem "dotenv-rails", "~> 2.1", ">= 2.1.1"

  gem "resque", "~> 2.0.0"
  gem "resque-scheduler", "~> 4.4"
end

group :test do
  gem "database_cleaner"
  gem "rspec-rails"
end
