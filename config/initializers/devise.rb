# frozen_string_literal: true

Devise.setup do |config|
  # In the future this is going to be 0 as default. We need to have unconfirmed access so that
  # participant can verify his/her email. And changing Decidim.unconfirmed_access_for
  # doesn't seem to work currently.
  config.allow_unconfirmed_access_for = 1000.days
end
