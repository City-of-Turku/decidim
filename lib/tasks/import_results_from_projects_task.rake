# frozen_string_literal: true

# Usage: bundle exec rake turku:budgets:import_projects_to_results[<budget component id>,<accountability component id>]

namespace :turku do
  namespace :budgets do
    desc "Create results from the projects that are selected to implementation"
    task :import_projects_to_results, [:budget_component_id, :accountability_component_id] => [:environment] do |_t, args|
      budget_component_id = args[:budget_component_id]
      accountability_component_id = args[:accountability_component_id]

      results_from_projects(budget_component_id, accountability_component_id)
    end

    private

    def results_from_projects(budget_component_id, accountability_component_id)
      accountability_component = Decidim::Component.find_by(id: accountability_component_id, manifest_name: "accountability")
      projects(budget_component_id).map do |project|
        next if project_already_copied?(project)

        new_result = create_result_from_project!(project, accountability_component)

        new_result.link_resources([project], "included_projects")
        project.linked_resources(:proposals, "included_proposals").each do |proposal|
          new_result.link_resources(proposal, "included_proposals")
        end
        copy_attachments(project, new_result)
      end
    end

    def create_result_from_project!(project, accountability_component)
      Decidim::Accountability::Result.create!(
        title: project.title,
        description: project.description,
        category: project.category,
        scope: project.scope || project.budget.scope,
        component: accountability_component
      )
    end

    def project_already_copied?(project)
      project.resource_links_to.where(from_type: "Decidim::Accountability::Result", name: "included_projects").any?
    end

    def projects(budget_component_id)
      budgets = Decidim::Budgets::Budget.where(component: budget_component_id)
      projects = Decidim::Budgets::Project.where(budget: budgets)
      projects.select { |project| project.selected_at.present? }
    end

    def copy_attachments(project, result)
      project.attachments.each do |attachment|
        new_attachment = Decidim::Attachment.new(
          {
            # Attached to needs to be always defined before the file is set
            attached_to: result
          }.merge(
            attachment.attributes.slice("content_type", "description", "file_size", "title", "weight")
          )
        )

        if attachment.file.attached?
          new_attachment.file = attachment.file.blob
        else
          new_attachment.attached_uploader(:file).remote_url = attachment.attached_uploader(:file).url(host: project.organization.host)
        end

        new_attachment.save!
      rescue Errno::ENOENT, OpenURI::HTTPError => e
        Rails.logger.warn("[ERROR] Couldn't copy attachment from proposal #{project.id} when copying to component due to #{e.message}")
      end
    end
  end
end
