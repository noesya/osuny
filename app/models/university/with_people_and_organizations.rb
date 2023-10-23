module University::WithPeopleAndOrganizations
  extend ActiveSupport::Concern

  included do
    has_many  :university_people,
              class_name: 'University::Person',
              dependent: :destroy
    alias_method :people, :university_people

    has_many  :university_person_categories,
              class_name: 'University::Person::Category',
              dependent: :destroy
    alias_method :person_categories, :university_person_categories

    has_many  :university_organizations,
              class_name: 'University::Organization',
              dependent: :destroy
    alias_method :organizations, :university_organizations

    has_many  :university_organization_categories,
              class_name: 'University::Organization::Category',
              dependent: :destroy
    alias_method :organization_categories, :university_organization_categories

    has_many  :person_experiences,
              class_name: 'University::Person::Experience',
              dependent: :destroy
    alias_method :university_person_experiences, :person_experiences
  end

end
