# frozen_string_literal: true

require "rails_helper"

describe Decidim::Budgets::Admin::VoteReminderGenerator do
  subject { described_class.new(component) }

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, organization: organization) }
  let(:budget) { create(:budget, component: component) }
  let!(:order) { create(:order, user: user, budget: budget) }
  let!(:order2) { create(:order, user: user2, budget: budget) }
  let!(:order3) { create(:order, user: user3, budget: budget) }
  let(:orders) { [order, order2, order3] }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:user2) { create(:user, :confirmed, organization: organization) }
  let(:user3) { create(:user, :confirmed, organization: organization) }

  before do
    orders.each do |o|
      o.update(checked_out_at: nil)
    end
  end

  describe "#generate" do
    it "creates reminders" do
      reminders = subject.generate

      expect(reminders.count).to eq(3)
      expect(reminders).to all(be_kind_of(Decidim::Budgets::VoteReminder))
    end
  end
end
