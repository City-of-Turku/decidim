# frozen_string_literal: true

require "rails_helper"

describe "Executing Decidim Metrics tasks" do
  describe "rake decidim:metrics:all", type: :task do
    let(:organization) { create(:organization) }
    let!(:user) { create(:user, organization: organization) }
    let(:component) { create(:component, manifest_name: "budgets", organization: organization) }
    let(:budget) { create(:budget, component: component) }
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
      end

      it "have to be executed without failures" do
        Rake::Task[:"turku:budgets:remind"].reenable
        expect { Rake::Task[:"turku:budgets:remind"].invoke }.not_to raise_error
      end

      it "enques job" do
        expect(Turku::VoteReminderJob).to receive(:perform_now).once

        Rake::Task[:"turku:budgets:remind"].invoke
      end
    end
  end
end
