# frozen_string_literal: true

require "rails_helper"

describe Decidim::Admin::VoteReminderJob do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:component) { create(:budgets_component, organization: organization) }
  let(:budget) { create(:budget, component: component) }
  let!(:order) { create(:order, user: user, budget: budget) }
  let(:vote_reminder) { Decidim::Budgets::VoteReminder.create(user: user, component: component) }
  let!(:voting_reminders) { [vote_reminder] }
  let(:subject) { described_class.new }

  before do
    allow(Rails.application.config).to receive(:reminder_times).and_return([2.hours, 1.week, 2.weeks])
  end

  context "when there is pending vote" do
    before do
      order.update(decidim_vote_reminder_id: vote_reminder.id, created_at: 1.week.ago, updated_at: 1.week.ago, checked_out_at: nil)
    end

    describe "#perform" do
      it "creates delivery job" do
        expect(Decidim::Admin::VoteReminderDeliveryJob).to receive(:perform_later).once.with(vote_reminder)

        subject.perform(voting_reminders)

        expect(vote_reminder.times.first).to be_between(1.minute.ago, Time.current)
      end
    end
  end

  context "when order is just created" do
    before do
      order.update(decidim_vote_reminder_id: vote_reminder.id, created_at: 10.minutes.ago, updated_at: 10.minutes.ago, checked_out_at: nil)
    end

    describe "#perform" do
      it "does not create delivery job" do
        expect(Decidim::Admin::VoteReminderDeliveryJob).not_to receive(:perform_later)

        subject.perform(voting_reminders)

        expect(vote_reminder.times).to be_empty
      end
    end
  end

  context "when user is already reminded maximum times" do
    before do
      order.update(decidim_vote_reminder_id: vote_reminder.id, created_at: 1.week.ago, updated_at: 1.week.ago, checked_out_at: nil)
      vote_reminder.update(times: [2.hours.ago, 1.week.ago, 2.weeks.ago])
    end

    describe "#perform" do
      it "does not create delivery job" do
        expect(Decidim::Admin::VoteReminderDeliveryJob).not_to receive(:perform_later)

        subject.perform(voting_reminders)

        expect(vote_reminder.times.count).to eq(3)
      end
    end
  end
end
