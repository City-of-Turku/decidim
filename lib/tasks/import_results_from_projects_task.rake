# frozen_string_literal: true

namespace :turku do
  namespace :accountability do
    # Usage: bundle exec rake turku:accountability:import_results_from_projects[<accountability component id>,<budget component id>]
    desc "Create results from the projects that are selected to implementation"
    task :import_results_from_projects, [:accountability_component_id, :budget_component_id] => [:environment] do |_t, args|
      accountability_component_id = args[:accountability_component_id]
      budget_component_id = args[:budget_component_id]

      results_from_projects(budget_component_id, accountability_component_id)
    end

    private

    def results_from_projects(budget_component_id, accountability_component_id)
      accountability_component = Decidim::Component.find_by(id: accountability_component_id, manifest_name: "accountability")
      raise ArgumentError.new, "Can't find accountability component!" unless accountability_component

      budgets = Decidim::Budgets::Budget.where(component: budget_component_id)
      raise ArgumentError.new, "Can't find budgets!" unless budgets

      projects(budgets).map do |project|
        next if project_already_copied?(project, accountability_component)

        new_result = create_result_from_project!(project, accountability_component)

        new_result.link_resources([project], "included_projects")
        new_result.link_resources(project.linked_resources(:proposals, "included_proposals"), "included_proposals")

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

    def project_already_copied?(project, target_component)
      project.resource_links_to.where(
        name: "included_projects",
        from_type: "Decidim::Accountability::Result"
      ).any? do |link|
        link.from.component == target_component
      end
    end

    def projects(budgets)
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
        Rails.logger.warn("[ERROR] Couldn't copy attachment from project #{project.id} when copying to component due to #{e.message}")
      end
    end
  end
end
