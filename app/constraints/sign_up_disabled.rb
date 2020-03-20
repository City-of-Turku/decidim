# frozen_string_literal: true

class SignUpDisabled
  def matches?(request)
    env = request.env

    @organization = env["decidim.current_organization"]
    return false unless @organization

    warden = env["warden"]
    return false if warden.authenticate(scope: :user)

    !@organization.sign_up_enabled?
  end
end
