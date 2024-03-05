# frozen_string_literal: true

namespace :users do
  # Sets the Tunnistamo default email for the given user to free this email for
  # another user account. Tunnistamo has a problem that previous users can be
  # "hogging" the user's actual email address because the identification methods
  # have changed.
  #
  # Usage:
  #   bundle exec rake users:set_tunnistamo_default_email[123]
  #   bundle exec rake users:set_tunnistamo_default_email[user@example.org]
  desc "Sets a Tunnistamo identified user the default Tunnistamo email."
  task :set_tunnistamo_default_email, [:user_id_or_email] => [:environment] do |_t, args|
    user_id = args[:user_id_or_email]
    unless user_id
      puts "Please provide the user ID or email as the first argument."
      next
    end

    user =
      if user_id.to_s.match?(/^[0-9]+$/)
        Decidim::User.entire_collection.find_by(id: user_id)
      else
        Decidim::User.entire_collection.find_by(email: user_id)
      end
    unless user
      puts "Unknown user ID or email: #{user_id}"
      next
    end

    identity = Decidim::Identity.find_by(provider: "tunnistamo", user: user)
    unless identity
      puts "The user has not been identified with Tunnistamo."
      next
    end

    digest = Digest::MD5.hexdigest("#{identity.uid}:#{Rails.application.secrets.secret_key_base}")
    user.email = "tunnistamo-#{digest}@#{user.organization.host}"
    user.unconfirmed_email = nil
    user.skip_reconfirmation!
    user.save(validate: false)

    puts "User email set to Tunnistamo default for user: #{user.id}"
  end
end
