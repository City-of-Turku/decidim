# frozen_string_literal: true

require "rails_helper"
require "decidim/api/test/type_context"

module Turku
  module Api
    describe ActivityType, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::Api::QueryType }

      let(:current_organization) { create(:organization) }
      let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }
      let(:user) { create(:user, :confirmed, organization: current_organization) }
      let!(:model) do
        create(
          :action_log,
          user: user,
          action: action,
          resource: resource,
          extra: extra,
          visibility: visibility,
          created_at: 1.minute.ago
        )
      end
      let(:action) { "publish" }
      let(:resource) { create(:dummy_resource) }
      let(:visibility) { "public-only" }
      let(:extra) { { "foo" => "bar" } }

      let(:query) do
        %(
          {
            user(id: #{user.id}) {
              activityTypes {
                #{field}
              }
            }
          }
        )
      end

      describe "id" do
        let(:field) { "id" }

        context "when visibility is private-only" do
          let(:visibility) { "private-only" }

          context "when current user is admin" do
            let(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

            it "returns the activity's id" do
              expect(response["user"]["activityTypes"].count).to eq(1)
              expect(response["user"]["activityTypes"].first).to include("id" => model.id.to_s)
            end
          end

          context "when current user is not admin" do
            let(:current_user) { create(:user, :confirmed, organization: current_organization) }

            before { user.update!(published_at: Time.current) }

            it "doesnt return activityTypes" do
              expect(response["user"]["activityTypes"].count).to eq(0)
            end
          end
        end
      end

      describe "resourceType" do
        let(:field) { "resourceType" }

        it "returns the activity's resourceType" do
          expect(response["user"]["activityTypes"].first).to include("resourceType" => model.resource_type.to_s)
        end
      end

      describe "resource" do
        let(:field) { "resource" }

        it "returns the activity's resource" do
          expect(response["user"]["activityTypes"].first).to include("resource" => resource)
        end
      end

      describe "extra" do
        let(:field) { "extra" }

        it "returns the activity's extra" do
          expect(response["user"]["activityTypes"].first).to include("extra" => extra)
        end
      end

      describe "visibility" do
        let(:field) { "visibility" }

        it "returns the activity's visibility" do
          expect(response["user"]["activityTypes"].first).to include("visibility" => visibility)
        end
      end
    end
  end
end
