# frozen_string_literal: true

class TurkuTunnistamoActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
  attr_reader :allowed_districts

  # Overrides the parent class method, but it still uses it to keep the base
  # behavior
  def authorize
    status_code, data = *super

    return [status_code, data] unless status_code == :ok

    if authorization.metadata["service"] == "turku_suomifi"
      minimum_age = options["minimum_age"].to_i || 0
      allowed_municipalities = options["suomifi_municipalities"].to_s.split(",").compact.collect(&:to_s)

      if options["allow_suomifi"].to_i == 0
        status_code = :unauthorized
        data[:extra_explanation] = {
          key: "disallowed_service",
          params: {
            scope: "turku_tunnistamo_action_authorizer.restrictions",
            service: I18n.t("turku_tunnistamo_action_authorizer.service.turku_suomifi")
          }
        }
      elsif !allowed_municipalities.include?(authorization.metadata["municipality_code"])
        status_code = :unauthorized
        data[:extra_explanation] = {
          key: "disallowed_municipality",
          params: {
            scope: "turku_tunnistamo_action_authorizer.restrictions"
          }
        }
      elsif authorization_age < minimum_age
        status_code = :unauthorized
        data[:extra_explanation] = {
          key: "too_young",
          params: {
            scope: "turku_tunnistamo_action_authorizer.restrictions",
            minimum_age: minimum_age
          }
        }
      end
    elsif authorization.metadata["service"] == "opas_adfs"
      allowed_roles ||= options["opasid_role"].to_s.split(",").compact.collect(&:strip)

      if options["allow_opasid"].to_i == 0
        status_code = :unauthorized
        data[:extra_explanation] = {
          key: "disallowed_service",
          params: {
            scope: "turku_tunnistamo_action_authorizer.restrictions",
            service: I18n.t("turku_tunnistamo_action_authorizer.service.opas_adfs")
          }
        }
      elsif !allowed_roles.empty? && !allowed_roles.include?(authorization.metadata["role"])
        status_code = :unauthorized
        data[:extra_explanation] = {
          key: "disallowed_opasid_role",
          params: {
            scope: "turku_tunnistamo_action_authorizer.restrictions"
          }
        }
      end
    elsif authorization.metadata["service"] == "axiell_aurora"
      minimum_age = options["minimum_age"].to_i || 0

      if options["allow_library_card"].to_i == 0
        status_code = :unauthorized
        data[:extra_explanation] = {
          key: "disallowed_service",
          params: {
            scope: "turku_tunnistamo_action_authorizer.restrictions",
            service: I18n.t("turku_tunnistamo_action_authorizer.service.axiell_aurora")
          }
        }
      elsif authorization_age < minimum_age
        status_code = :unauthorized
        data[:extra_explanation] = {
          key: "too_young",
          params: {
            scope: "turku_tunnistamo_action_authorizer.restrictions",
            minimum_age: minimum_age
          }
        }
      end
    else
      # Turku employees / Tunnistamo other authorizations.
      status_code = :unauthorized
      data[:extra_explanation] = {
        key: "disallowed_service",
        params: {
          scope: "turku_tunnistamo_action_authorizer.restrictions",
          service: I18n.t("turku_tunnistamo_action_authorizer.service.axiell_aurora")
        }
      }
    end

    # In case reauthorization is allowed (i.e. no votes have been casted),
    # show the reauthorization modal that takes the user back to the "new"
    # action in the authorization handler.
    if status_code == :unauthorized && allow_reauthorization?
      return [
        :incomplete,
        extra_explanation: data[:extra_explanation],
        action: :reauthorize,
        cancel: true
      ]
    end

    [status_code, data]
  end

  # Adds the list of allowed districts codes to the redirect URL, to allow
  # forms to inform about it
  def redirect_params
    { "districts" => allowed_districts&.join("-") }
  end

  protected

  # The option field names do not match the metadata fields, so we check them
  # manually.
  def missing_fields
    @missing_fields ||= []
  end

  private

  def allow_reauthorization?
    return false if authorization.metadata["service"] == "turku_suomifi"
    return true unless component
    return false unless component.manifest_name == "budgets"
    return true unless authorization.user

    Decidim::Budgets::Order.where(
      component: component,
      user: authorization.user
    ).where.not(checked_out_at: nil).count == 0
  end

  def authorization_age
    return 0 if authorization.metadata["birthdate"].blank?

    @authorization_age ||= begin
      now = Time.now.utc.to_date
      bd = Date.strptime(authorization.metadata["birthdate"], "%Y-%m-%d")
      now.year - bd.year - (bd.to_date.change(year: now.year) > now ? 1 : 0)
    end
  end
end
