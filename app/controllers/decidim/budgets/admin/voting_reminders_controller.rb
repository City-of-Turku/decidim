# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class VotingRemindersController < Admin::ApplicationController
        def new
          enforce_permission_to :create, :budget
          @form = form(VotingReminderForm).instance

          render :new
        end

        def create
          enforce_permission_to :create, :budget
          @form = form(VotingReminderForm).from_params(params, current_component: current_component)

          CreateVotingReminders.call(@form) do
            on(:ok) do |reminder_data|
              flash[:notice] = "success #{reminder_data.count}"
              redirect_to budgets_path
            end

            on(:invalid) do
              flash.now[:alert] = "failed"
              render action: "reminders"
            end
          end
        end
      end
    end
  end
end
