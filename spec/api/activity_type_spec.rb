# frozen_string_literal: true

require "rails_helper"
require "decidim/api/test/type_context"

module Decidim
  module Turku
    describe ActivityType, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::Api::QueryType }

      let(:current_organization) { create(:organization) }
      let(:user) { create(:user, organization: current_organization) }
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
            activity(userId: #{user.id}) {
              #{field}
            }
          }
        )
      end

      describe "id" do
        let(:field) { "id" }

        it "returns the activity's id" do
          expect(response["activity"]).to include("id" => model.id.to_s)
        end
      end

      describe "resourceType" do
        let(:field) { "resourceType" }

        it "returns the activity's resourceType" do
          expect(response["activity"]).to include("resourceType" => model.resource_type.to_s)
        end
      end

      describe "resource" do
        let(:field) { "resource" }

        it "returns the activity's resource" do
          expect(response["activity"]).to include("resource" => resource)
        end
      end

      describe "extra" do
        let(:field) { "extra" }

        it "returns the activity's extra" do
          expect(response["activity"]).to include("extra" => extra)
        end
      end

      describe "visibility" do
        let(:field) { "visibility" }

        it "returns the activity's visibility" do
          expect(response["activity"]).to include("visibility" => visibility)
        end
      end
    end
  end
end
