# frozen_string_literal: true

require "rails_helper"

module Decidim
  # Tests the core omniauth registrations command with our customizations.
  describe CreateOmniauthRegistration do
    subject { described_class.new(form, verified_email) }

    let(:organization) { create(:organization) }

    let(:form) do
      Decidim::OmniauthRegistrationForm.from_params(
        email: verified_email,
        unconfirmed_email: unconfirmed_email,
        email_confirmed: email_confirmed,
        name: "John Doe",
        nickname: "john_doe",
        provider: "tunnistamo",
        uid: "abc123",
        tos_agreement: true,
        oauth_signature: Digest::MD5.hexdigest("tunnistamo-abc123-#{Rails.application.secrets.secret_key_base}"),
        avatar_url: nil,
        raw_data: {}
      ).with_context(current_organization: organization)
    end
    let(:verified_email) { Faker::Internet.email }
    let(:unconfirmed_email) { "john.doe@example.org" }
    let(:email_confirmed) { false }

    before do
      allow(::Decidim::Tunnistamo).to receive(:confirm_emails).and_return(true)
    end

    context "when the form is valid" do
      let(:user) { Decidim::User.entire_collection.last }

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a new user" do
        subject.call
        expect(user.email).to eq(form.email)
        expect(user.name).to eq(form.name)
        expect(user.nickname).to match(/^u_\d+/)
        # The tos agreement should not be set, the `tos_agreement` is only
        # needed in order for the user record to be created but they should not
        # automatically accept the TOS.
        expect(user.tos_accepted?).to be(false)
      end

      it "marks the unconfirmed email for the new user and generates a confirmation token" do
        subject.call

        expect(user.confirmed_at).to be_nil
        expect(user.unconfirmed_email).to eq(unconfirmed_email)
        expect(user.confirmation_token).not_to be_nil
      end

      context "with an unconfirmed existing user without confirmation token" do
        let!(:user) { create(:user, organization: organization) }
        let!(:identity) { create(:identity, user: user, provider: form.provider, uid: form.uid) }

        it "creates a confirmation token during the omniauth registration creation" do
          user.update!(confirmation_token: nil)
          expect { subject.call }.not_to change(Decidim::User.entire_collection, :count)

          user.reload
          expect(user.confirmation_token).not_to be_nil
        end
      end

      context "with the email being confirmed" do
        let(:verified_email) { "john.doe@example.org" }
        let(:unconfirmed_email) { nil }
        let(:email_confirmed) { true }

        it "creates a new user without requiring email confirmation" do
          subject.call
          expect(user.email).to eq(form.email)
          expect(user.confirmed_at).not_to be_nil
          expect(user.unconfirmed_email).to be_nil
          expect(user.confirmation_token).to be_nil
        end
      end
    end
  end
end
