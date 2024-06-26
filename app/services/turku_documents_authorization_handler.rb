# frozen_string_literal: true

# This class provides a way for users to enter their Finnish personal identity
# codes (PIN/HETU) in the system along with their postal code OR just their
# postal code. It can be used as a lightweight method for providing traceability
# against specific actions that the users are performing in the system.
class TurkuDocumentsAuthorizationHandler < Decidim::AuthorizationHandler
  attribute :handler_context_verification, String

  attribute :document_type, Symbol
  attribute :pin, String
  attribute :first_name, String
  attribute :last_name, String
  attribute :postal_code, String

  validates :context, presence: true
  validates :document_type, presence: true, inclusion: { in: [:passport, :idcard, :drivers_license, :kela_card] }
  validates :pin, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :postal_code, presence: true, length: { is: 5 }, format: { with: /\A[0-9]*\z/ }

  validate :validate_impersonation
  validate :validate_pin

  # Sets up the handler for the different contexts based on the controller.
  # The context is obfuscated to make it harder for the potential attackers to
  # misuse the authorization. It is later converted back to the actual context
  # when the form is submitted with the obfuscated context.
  def setup(controller)
    self.handler_context_verification = begin
      if controller.instance_of?(Decidim::Admin::ImpersonationsController)
        generate_context_verification(:impersonation)
      else
        generate_context_verification(:user)
      end
    end
  end

  def context
    determine_context handler_context_verification
  end

  # If you need to store any of the defined attributes in the authorization
  # you can do it here.
  #
  # You must return a Hash that will be serialized to the authorization when
  # it's created, and available though authorization.metadata
  def metadata
    gender = nil
    date_of_birth = nil
    if hetu
      gender =
        if hetu.gender_neutral?
          nil
        else
          hetu.male? ? "m" : "f"
        end
      date_of_birth = hetu.date_of_birth.to_s
    end

    super.merge(
      document_type: sanitized_document_type,
      gender: gender,
      date_of_birth: date_of_birth,
      pin_digest: pin_digest,
      first_name: first_name,
      last_name: last_name,
      postal_code: postal_code,
      municipality: "853"
    )
  end

  def document_types
    [:passport, :idcard, :drivers_license, :kela_card].map do |type|
      [I18n.t(type, scope: "decidim.authorization_handlers.turku_documents_authorization_handler.document_types"), type]
    end
  end

  def unique_id
    Digest::MD5.hexdigest(
      "DOC:#{pin}:#{Rails.application.secrets.secret_key_base}"
    )
  end

  def pin_digest
    Digest::MD5.hexdigest(
      "FI:#{pin}:#{Rails.application.secrets.secret_key_base}"
    )
  end

  private

  def impersonation?
    context == :impersonation
  end

  def generate_context_verification(context)
    salt = Rails.application.secrets.secret_key_base
    Digest::MD5.hexdigest("#{salt}-#{context}")
  end

  def determine_context(verification)
    salt = Rails.application.secrets.secret_key_base

    [:impersonation, :user].each do |context|
      return context if verification == Digest::MD5.hexdigest("#{salt}-#{context}")
    end

    nil
  end

  def validate_impersonation
    errors.add(:document_type, :invalid) unless impersonation?
  end

  def validate_pin
    return if pin.blank?

    errors.add(:pin, :invalid_pin) unless hetu.valid?
  end

  def sanitized_document_type
    case document_type&.to_sym
    when :passport
      "01"
    when :idcard
      "02"
    when :drivers_license
      "03"
    when :kela_card
      "04"
    end
  end

  def age
    return nil unless hetu

    hetu.age
  end

  def date_of_birth
    return unless hetu

    hetu.date_of_birth
  end

  def hetu
    return nil if pin.blank?

    @hetu ||= Henkilotunnus::Hetu.new(pin)
  end
end
