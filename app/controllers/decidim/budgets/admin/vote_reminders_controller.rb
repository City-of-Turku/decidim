# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class VoteRemindersController < Admin::ApplicationController
        def new
          enforce_permission_to :create, :budget
          @form = form(VoteReminderForm).instance

          render :new
        end

        def create
          enforce_permission_to :create, :budget
          @form = form(VoteReminderForm).from_params(params, current_component: current_component)

          CreateVoteReminders.call(@form) do
            on(:ok) do |reminder_data|
              flash[:notice] = t("vote_reminders.create.success", scope: "decidim.budgets.admin", count: reminder_data.count)
              redirect_to budgets_path
            end

            on(:invalid) do
              flash.now[:alert] = t("vote_reminders.create.error", scope: "decidim.budgets.admin")
              render action: "new"
            end
          end
        end
      end
    end
  end
end
