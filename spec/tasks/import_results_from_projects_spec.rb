# frozen_string_literal: true

require "rails_helper"

describe "rake turku:budgets:import_results_from_projects", type: :task do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization: organization) }

  let(:accountability_component) { create(:component, manifest_name: "accountability", participatory_space: participatory_space, published_at: accountability_compoennt_published_at) }
  let(:accountability_compoennt_published_at) { nil }

  let(:budget_component) { create(:component, manifest_name: "budgets", participatory_space: participatory_space) }
  let(:budget) { create(:budget, component: budget_component, total_budget: 26_000_000) }
  let(:project) { create(:project, budget: budget, selected_at: selected_at) }
  let(:selected_at) { Time.current }

  let(:task) { :"turku:budgets:import_results_from_projects" }

  shared_examples "import project to result" do
    it "creates new result" do
      Rake::Task[task].invoke(accountability_component.id, budget_component.id)

      expect(Decidim::Accountability::Result.count).to eq(1)
      result = Decidim::Accountability::Result.first
      expect(result.title).to eq(project.title)
      expect(result.description).to eq(project.description)
      expect(project.resource_links_to.count).to eq(1)
      expect(project.resource_links_to.first.from).to eq(result)
    end
  end

  context "when re enable rake task" do
    before do
      Rake::Task[task].reenable
    end

    context "when there is project" do
      let!(:projects) { [project] }

      it_behaves_like "import project to result"

      it "doesnt extra result when ran twice" do
        Rake::Task[task].invoke(accountability_component.id, budget_component.id)
        expect(Decidim::Accountability::Result.count).to eq(1)
        Rake::Task[task].reenable
        Rake::Task[task].invoke(accountability_component.id, budget_component.id)

        expect(Decidim::Accountability::Result.count).to eq(1)
      end

      context "when accountability component is published" do
        let(:accountability_compoennt_published_at) { Time.current }

        it_behaves_like "import project to result"

        context "when project is linked to a proposal" do
          let(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_space) }
          let(:proposal) { create(:proposal, component: proposals_component) }

          before do
            project.link_resources(proposal, "included_proposals")
          end

          it "links result to project and proposal" do
            Rake::Task[task].invoke(accountability_component.id, budget_component.id)

            expect(Decidim::Accountability::Result.count).to eq(1)
            result = Decidim::Accountability::Result.last
            expect(result.linked_resources(:proposals, "included_proposals").first).to eq(proposal)
            expect(result.linked_resources(:projects, "included_projects").first).to eq(project)
          end
        end
      end

      context "when not selected" do
        let(:selected_at) { nil }

        it "doesnt create result" do
          Rake::Task[task].invoke(accountability_component.id, budget_component.id)

          expect(Decidim::Accountability::Result.count).to eq(0)
        end
      end

      context "when project has a category" do
        let(:category) { create :category, participatory_space: participatory_space }

        before do
          project.update(category: category)
        end

        it "adds category to result" do
          Rake::Task[task].invoke(accountability_component.id, budget_component.id)

          expect(Decidim::Accountability::Result.count).to eq(1)
          expect(Decidim::Accountability::Result.first.category).to eq(category)
        end
      end

      context "when project has a scope" do
        let(:scope) { create :scope, organization: organization }

        before do
          project.update(scope: scope)
        end

        it "adds category to result" do
          Rake::Task[task].invoke(accountability_component.id, budget_component.id)

          expect(Decidim::Accountability::Result.count).to eq(1)
          expect(Decidim::Accountability::Result.first.scope).to eq(scope)
        end
      end

      context "when project has attachments" do
        let(:image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
        let(:document) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
        let!(:attachment) { create(:attachment, attached_to: project, file: image) }
        let!(:attachment2) { create(:attachment, attached_to: project, file: document) }

        it "copies attachments to result" do
          Rake::Task[task].invoke(accountability_component.id, budget_component.id)

          expect(Decidim::Accountability::Result.count).to eq(1)
          result = Decidim::Accountability::Result.last
          expect(result.attachments.count).to eq(2)
          image_attachment = result.attachments.select { |attachment| attachment.content_type == "image/jpeg" }.first
          document_attachment = result.attachments.select { |attachment| attachment.content_type == "application/pdf" }.first
          expect(image_attachment.title).to eq(attachment.title)
          expect(document_attachment.title).to eq(attachment2.title)
        end
      end
    end

    context "when there are many projects" do
      let(:project2) { create(:project, budget: budget) }
      let(:project3) { create(:project, budget: budget, selected_at: selected_at) }
      let!(:projects) { [project, project2, project3] }

      it "creates result on every selected project" do
        Rake::Task[task].invoke(accountability_component.id, budget_component.id)

        expect(Decidim::Accountability::Result.count).to eq(2)
      end
    end
  end
end
