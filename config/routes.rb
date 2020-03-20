Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  constraints SignUpDisabled.new do
    root to: "placeholder#index"
  end

  mount Decidim::Core::Engine => "/"
end
