# frozen_string_literal: true

require "rails_helper"

describe "Admin sends vote reminders", type: :system do
  include_context "when managing a component as an admin"
  let(:organization) { create(:organization, available_locales: [:en, :fi]) }
  let(:user) { create(:user, :admin, :confirmed, name: "Sarah Kerrigan", organization: organization, locale: "en") }
  let(:user2) { create(:user, :confirmed, name: "Jim Raynor", organization: organization, locale: "en") }
  let(:component) { create(:component, manifest_name: "budgets", organization: organization) }
  let(:budget) { create(:budget, component: component, total_budget: 26_000_000) }
  let(:projects) { create_list(:project, 1, budget: budget, budget_amount: 25_000_000) }

  let!(:order) do
    order = create(:order, user: user, budget: budget)
    order.projects << projects
    order.save!
    order
  end

  let!(:order2) do
    order = create(:order, user: user2, budget: budget)
    order.projects << projects
    order.save!
    order
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
    click_link "Send voting reminders"
  end

  describe "new vote reminder" do
    it "shows how many people are being reminded" do
      expect(page).to have_content("Are you sure you want to send reminder to 2 people?")
    end
  end

  describe "create vote reminders" do
    it "sends reminders" do
      click_button "Send"
      expect(page).to have_content("2 people reminded.")
      expect(emails.count).to eq(2)
      emails.each do |email|
        expect(email.subject).to eq("You have an unfinished vote in the participatory budgeting vote")
      end
      expect(last_email_first_link).to eq("/processes/#{component.participatory_space.slug}/f/#{component.id}/budgets/#{budget.id}")
      expect(last_email_link).to eq("/processes/#{component.participatory_space.slug}/f/#{component.id}/")
    end

    it "doesnt remind twice" do
      click_button "Send"
      click_link "Send voting reminders"
      click_button "Send"
      expect(page).to have_content("0 people reminded.")
    end
  end
end
