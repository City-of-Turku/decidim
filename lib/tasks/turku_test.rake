# frozen_string_literal: true

namespace :turku_test do
  desc "Import test proposals."
  task :import_proposals, [:component_id, :filename] => [:environment] do |_t, args|
    component_id = args[:component_id]
    component = Decidim::Component.find_by(id: component_id)
    if component.nil? || component.manifest_name != "proposals"
      puts "Invalid component provided: #{component_id}."
      next
    end
    filename = args[:filename]
    unless File.exist?(filename)
      puts "File does not exist at: #{filename}"
      next
    end

    organization = component.organization
    test_users = test_users_for(organization)

    require "csv"
    CSV.foreach(filename, col_sep: ";", headers: true) do |row|
      author = test_users.sample
      scope = organization.scopes.find_by(id: row["scope/id"])

      puts "Importing proposal: #{row["title/fi"]}"
      attributes = {
        title: { fi: row["title/fi"] },
        body: { fi: row["body/fi"] },
        scope: scope,
        component: component,
        address: row["address"],
        latitude: row["latitude"],
        longitude: row["longitude"],
        published_at: Time.current
      }
      Decidim::Proposals::ProposalBuilder.create(
        attributes: attributes,
        author: author,
        action_user: author
      )
    end
  end

  def test_users_for(organization)
    require "faker"
    Faker::Config.locale = "fi"

    [
      "info+turkutest1@mainiotech.fi",
      "info+turkutest2@mainiotech.fi",
      "info+turkutest3@mainiotech.fi",
      "info+turkutest4@mainiotech.fi",
      "info+turkutest5@mainiotech.fi",
      "info+turkutest6@mainiotech.fi",
      "info+turkutest7@mainiotech.fi",
      "info+turkutest8@mainiotech.fi",
      "info+turkutest9@mainiotech.fi",
      "info+turkutest10@mainiotech.fi"
    ].map do |email|
      user = Decidim::User.entire_collection.find_by(email: email)
      unless user
        pw = SecureRandom.hex
        name = Faker::Name.name
        user = Decidim::User.new(
          organization: organization,
          email: email,
          name: name,
          nickname: Decidim::UserBaseEntity.nicknamize(name, organization: organization),
          confirmed_at: Time.current,
          published_at: Time.current,
          password: pw,
          password_confirmation: pw,
          newsletter_notifications_at: nil
        )
        user.skip_confirmation!
        user.tos_agreement = "1"
        user.save!
      end

      user
    end
  end
end
