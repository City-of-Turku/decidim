# frozen_string_literal: true

require "rails_helper"

describe "Tunnistamo login", type: :system do
  let(:organization) { create(:organization) }

  context "when omniauth login" do
    let(:omniauth_hash) do
      OmniAuth::AuthHash.new(
        provider: :tunnistamo,
        uid: SecureRandom.uuid,
        info: {
          email: email,
          name: tunnistamo_user_name
        },
        extra: {
          raw_info: {
            oid: oid,
            birthdate: "1985-07-15"
          }
        }
      )
    end
    let(:tunnistamo_user_name) { ::Faker::Name.name }
    let(:email) { ::Faker::Internet.email }
    let(:oid) { Faker::Internet.uuid }

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:tunnistamo] = omniauth_hash
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    describe "tunnistamo login" do
      before { tunnistamo_login }

      it "adds turku pesudoanonymized oid to identity" do
        pseudoanonymized_oid = Digest::MD5.hexdigest("OID:#{oid}:#{Rails.application.secrets.secret_key_base}")
        expect(Decidim::Identity.last.turku_oid).to eq(pseudoanonymized_oid)
      end
    end
  end

  def tunnistamo_login
    click_link "Sign In"
    click_button "I agree with these terms"
  end
end
