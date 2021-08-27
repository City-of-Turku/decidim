# frozen_string_literal: true

require "rails_helper"

describe "Executing Decidim Metrics tasks" do
  describe "rake decidim:metrics:all", type: :task do
    let(:organization) { create(:organization) }
    let!(:user) { create(:user, organization: organization) }
    let(:component) { create(:component, manifest_name: "budgets", organization: organization) }
    let(:budget) { create(:budget, component: component, total_budget: 26_000_000) }
    let(:projects) { create_list(:project, 1, budget: budget, budget_amount: 25_000_000) }

    let!(:order) do
      order = create(:order, user: user, budget: budget)
      order.projects << projects
      order.save!
      order
    end

    after do
      clear_enqueued_jobs
    end

    context "when we reminder time is zero" do
      before do
        allow(Rails.application.config).to receive(:reminder_times).and_return(0.seconds)
        Rake::Task[:"turku:budgets:remind"].reenable
      end

      it "have to be executed without failures" do
        expect { Rake::Task[:"turku:budgets:remind"].invoke }.not_to raise_error
      end

      describe "when order is not checked out" do
        it "enques job" do
          expect(Turku::VoteReminderJob).to receive(:perform_now).once

          Rake::Task[:"turku:budgets:remind"].invoke
        end
      end

      describe "when order is checked out" do
        before do
          order.update!(checked_out_at: Time.current)
        end

        it "doesnt enque job" do
          expect(Turku::VoteReminderJob).not_to receive(:perform_now)

          Rake::Task[:"turku:budgets:remind"].invoke
        end
      end
    end
  end
end
