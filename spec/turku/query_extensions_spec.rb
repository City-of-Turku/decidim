# frozen_string_literal: true

require "rails_helper"
require "decidim/api/test/type_context"

module Decidim
  module Turku
    describe Decidim::Api::QueryType do
      include_context "with a graphql class type"

      let(:current_organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization: current_organization) }
      let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

      context "when user has voted" do
        let(:identity) { create(:identity, user: user, provider: "tunnistamo", uid: "12345") }
        let(:oid) { SecureRandom.uuid }
        let!(:action_log) do
          create(
            :action_log,
            user: user,
            action: "checkout",
            resource: order,
            visibility: visibility
          )
        end
        let(:visibility) { "private-only" }
        let(:component) do
          create(
            :budgets_component,
            organization: current_organization
          )
        end
        let(:budget) { create(:budget, component: component) }
        let!(:order) { create(:order, :with_projects, user: user, budget: budget) }
        let(:query) do
          %(
            {
              user(oid: "#{oid}") {
                activityTypes {
                  id
                  resourceType
                  visibility
                }
              }
            }
          )
        end

        before do
          identity.update(turku_oid: Digest::MD5.hexdigest("OID:#{oid}:#{Rails.application.secrets.secret_key_base}"))
        end

        it "returns activity's id" do
          expect(response["user"]["activityTypes"].first).to include("id" => action_log.id.to_s)
        end

        it "returns activity's resourceType" do
          expect(response["user"]["activityTypes"].first).to include("resourceType" => order.class.to_s)
        end

        it "returns activity's visibility" do
          expect(response["user"]["activityTypes"].first).to include("visibility" => visibility)
        end

        context "when current user is not admin" do
          let(:current_user) { create(:user, :confirmed, organization: current_organization) }

          it "raises action forbidden" do
            expect { response }.to raise_error(Decidim::ActionForbidden)
          end
        end
      end
    end
  end
end
