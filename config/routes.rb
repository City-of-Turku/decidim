# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # constraints SignUpDisabled.new do
  #   root to: "placeholder#index"
  # end

  mount Decidim::Core::Engine => "/"
end
