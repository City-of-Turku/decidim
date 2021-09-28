# frozen_string_literal: true

class UnconfirmUsersExceptVerified < ActiveRecord::Migration[5.2]
  def up
    Decidim::Authorization.where(name: "tunnistamo_idp").find_each do |authorization|
      next if authorization.metadata.is_a?(Hash) && %w(opas_adfs turku_adfs).include?(authorization.metadata["service"])

      authorization.user.update(confirmed_at: nil)
    end
  end
end
