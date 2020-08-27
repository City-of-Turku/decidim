# frozen_string_literal: true

# Add the identity code verification. Note that the name needs to match the
# authorization handler's name because of some internal logic with the handlers.
Decidim::Verifications.register_workflow(:turku_documents_authorization_handler) do |auth|
  auth.form = "TurkuDocumentsAuthorizationHandler"
  auth.expires_in = 1.month
end
