# frozen_string_literal: true

require "rails_helper"

describe "Executing Turku voting reminder tasks" do
  describe "rake turku:budgets:remind", type: :task do
    include ActiveSupport::Testing::TimeHelpers

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
          expect(Decidim::Admin::VoteReminderJob).to receive(:perform_now).once

          Rake::Task[:"turku:budgets:remind"].invoke
        end
      end

      describe "when order is checked out" do
        before do
          order.update!(checked_out_at: Time.current)
        end

        it "doesnt enque job" do
          expect(Decidim::Admin::VoteReminderJob).not_to receive(:perform_now)

          Rake::Task[:"turku:budgets:remind"].invoke
        end
      end
    end

    context "when not enough time has passed" do
      before do
        allow(Rails.application.config).to receive(:reminder_times).and_return(1.hour)
        Rake::Task[:"turku:budgets:remind"].reenable
      end

      it "doesnt enque job" do
        expect(Decidim::Admin::VoteReminderJob).not_to receive(:perform_now)

        Rake::Task[:"turku:budgets:remind"].invoke
      end
    end

    context "when there is reminder intervals" do
      it "does something" do
        allow(Rails.application.config).to receive(:reminder_times).and_return([1.hour, 1.week])
        expect(Decidim::Budgets::VoteReminder.count).to eq(0)

        travel 2.hours

        expect do
          Rake::Task[:"turku:budgets:remind"].reenable
          Rake::Task[:"turku:budgets:remind"].invoke
        end.to change { Decidim::Budgets::VoteReminder.count }.by(1)

        expect(Decidim::Budgets::VoteReminder.first.times.count).to eq(1)

        travel 1.day

        Rake::Task[:"turku:budgets:remind"].reenable
        Rake::Task[:"turku:budgets:remind"].invoke

        expect(Decidim::Budgets::VoteReminder.first.times.count).to eq(1)

        travel 1.week

        Rake::Task[:"turku:budgets:remind"].reenable
        Rake::Task[:"turku:budgets:remind"].invoke

        expect(Decidim::Budgets::VoteReminder.first.times.count).to eq(2)

        Rake::Task[:"turku:budgets:remind"].reenable
        Rake::Task[:"turku:budgets:remind"].invoke

        expect(Decidim::Budgets::VoteReminder.first.times.count).to eq(2)
        expect(Decidim::Budgets::VoteReminder.count).to eq(1)
      end
    end
  end
end
