# == Schema Information
#
# Table name: university_person_experiences
#
#  id              :uuid             not null, primary key
#  description     :text
#  from_year       :integer
#  to_year         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null, indexed
#  person_id       :uuid             not null, indexed
#  university_id   :uuid             not null, indexed
#
# Indexes
#
#  index_university_person_experiences_on_organization_id  (organization_id)
#  index_university_person_experiences_on_person_id        (person_id)
#  index_university_person_experiences_on_university_id    (university_id)
#
# Foreign Keys
#
#  fk_rails_18125d90df  (person_id => university_people.id)
#  fk_rails_38aaa18a3b  (organization_id => university_organizations.id)
#  fk_rails_923d0b71fd  (university_id => universities.id)
#
class University::Person::Experience < ApplicationRecord
  include Sanitizable
  include WithUniversity

  attr_accessor :organization_name

  belongs_to :person
  belongs_to :organization, class_name: "University::Organization"

  validates_presence_of :organization
  validates_presence_of :from_year
  # TODO validateur de comparaison
  # validates_numericality_of :to_year, { greater_than_or_equal_to: :from_year }, allow_nil: true
  validate :to_year, :not_before_from_year

  before_validation :create_organization_if_needed

  scope :current, -> { where('from_year <= :current_year AND (to_year IS NULL OR to_year >= :current_year)', current_year: Date.today.year) }
  scope :ordered, -> { order('university_person_experiences.to_year DESC NULLS FIRST, university_person_experiences.from_year') }
  scope :recent, -> {
    where.not(from_year: nil)
    .order(from_year: :desc, created_at: :desc)
    .limit(10)
  }

  def to_s
    persisted?  ? "#{description}"
                : self.class.human_attribute_name('new')
  end

  def organization_name
    @organization_name || organization&.name
  end

  private

  def not_before_from_year
    if to_year.present? && to_year < from_year
      errors.add :to_year
    end
  end

  def create_organization_if_needed
    if organization.nil? && organization_name.present?
      self.organization_name = self.organization_name.strip
      orga = university.organizations.find_by("name ILIKE ?", organization_name)
      orga ||= university.organizations.find_by(siren: organization_name)
      orga ||= university.organizations.create(name: organization_name, created_from_extranet: true)
      self.organization = orga if orga.persisted?
    end
  end
end
