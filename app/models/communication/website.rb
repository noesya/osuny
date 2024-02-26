# == Schema Information
#
# Table name: communication_websites
#
#  id                      :uuid             not null, primary key
#  about_type              :string           indexed => [about_id]
#  access_token            :string
#  autoupdate_theme        :boolean          default(TRUE)
#  default_time_zone       :string
#  deployment_status_badge :text
#  deuxfleurs_hosting      :boolean          default(TRUE)
#  deuxfleurs_identifier   :string
#  feature_agenda          :boolean          default(FALSE)
#  feature_posts           :boolean          default(TRUE)
#  git_branch              :string
#  git_endpoint            :string
#  git_provider            :integer          default("github")
#  in_production           :boolean          default(FALSE)
#  name                    :string
#  plausible_url           :string
#  repository              :string
#  social_email            :string
#  social_facebook         :string
#  social_github           :string
#  social_instagram        :string
#  social_linkedin         :string
#  social_mastodon         :string
#  social_peertube         :string
#  social_tiktok           :string
#  social_vimeo            :string
#  social_x                :string
#  social_youtube          :string
#  style                   :text
#  style_updated_at        :date
#  theme_version           :string           default("NA")
#  url                     :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  about_id                :uuid             indexed => [about_type]
#  default_language_id     :uuid             not null, indexed
#  university_id           :uuid             not null, indexed
#
# Indexes
#
#  index_communication_websites_on_about                (about_type,about_id)
#  index_communication_websites_on_default_language_id  (default_language_id)
#  index_communication_websites_on_university_id        (university_id)
#
# Foreign Keys
#
#  fk_rails_2b6d929310  (default_language_id => languages.id)
#  fk_rails_bb6a496c08  (university_id => universities.id)
#
class Communication::Website < ApplicationRecord
  self.filter_attributes += [:access_token]

  include Favoritable
  include WithAbouts
  include WithAssociatedObjects
  include WithConfigs
  include WithConnectedObjects
  include WithDependencies
  include WithDeuxfleurs
  include WithGit
  include WithGitRepository
  include WithLanguages
  include WithManagers
  include WithProgramCategories
  include WithReferences
  include WithSpecialPages
  include WithMenus # Menus must be created after special pages, so we can fill legal menu
  include WithScreenshot
  include WithSecurity
  include WithStyle
  include WithTheme
  include WithUniversity

  enum git_provider: {
    github: 0,
    gitlab: 1
  }

  has_one_attached_deletable :default_image
  validates :default_image, size: { less_than: 5.megabytes }

  has_one_attached_deletable :default_shared_image
  validates :default_shared_image, size: { less_than: 5.megabytes }

  before_validation :sanitize_fields

  scope :ordered, -> { order(:name) }
  scope :in_production, -> { where(in_production: true) }
  scope :for_production, -> (production) { where(in_production: production) }
  scope :for_search_term, -> (term) {
    where("
      unaccent(communication_websites.name) ILIKE unaccent(:term) OR
      unaccent(communication_websites.url) ILIKE unaccent(:term)
    ", term: "%#{sanitize_sql_like(term)}%")
  }
  scope :for_update, -> (autoupdate) { where(autoupdate_theme: autoupdate) }
  scope :with_url, -> { where.not(url: [nil, '']) }
  scope :with_access_token, -> { where.not(access_token: [nil, '']) }

  def to_s
    "#{name}"
  end

  def git_path(website)
    "data/website.yml"
  end

  def dependencies
    # Le website est le SEUL cas d'auto-dépendance
    [self] +
    configs +
    pages.where(language_id: language_ids) +
    posts.where(language_id: language_ids) +
    post_categories.where(language_id: language_ids) +
    events.where(language_id: language_ids) +
    agenda_categories.where(language_id: language_ids) +
    menus.where(language_id: language_ids) +
    [about] +
    [default_image&.blob]
  end

  def website
    self
  end

  def website_id
    id
  end

  # Override to follow direct objects
  def sync_with_git
    return unless website.git_repository.valid?
    if syncable?
      Communication::Website::GitFile.sync website, self
      dependencies_with_static_file.each do |dependency_global_id|
        Communication::Website::GitFile.sync website, GlobalID::Locator.locate(dependency_global_id)
      end
    end
    website.git_repository.sync!
  end
  handle_asynchronously :sync_with_git, queue: :default

  def move_to_university(new_university_id)
    return if self.university_id == new_university_id
    update_column :university_id, new_university_id
    recursive_dependencies_syncable_following_direct.each do |dependency|
      reconnect_dependency dependency, new_university_id
    end
  end

  protected

  def sanitize_fields
    self.git_branch = Osuny::Sanitizer.sanitize(self.git_branch, 'string')
    self.git_endpoint = Osuny::Sanitizer.sanitize(self.git_endpoint, 'string')
    self.name = Osuny::Sanitizer.sanitize(self.name, 'string')
    self.plausible_url = Osuny::Sanitizer.sanitize(self.plausible_url, 'string')
    self.repository = Osuny::Sanitizer.sanitize(self.repository, 'string')
    self.url = Osuny::Sanitizer.sanitize(self.url, 'string')
  end

  def reconnect_dependency(dependency, new_university_id)
    # puts
    # puts "reconnect dependency #{dependency} - #{dependency.class}"
    unless dependency.respond_to?(:university_id)
      # puts "no university"
      return
    end
    # puts "  respond to university_id"
    # vérifier par les connexions qu'un objet indirect n'est pas utilisé dans un autre website
    if dependency.respond_to?(:connections) && dependency.connections.where.not(website: self).any?
      # puts "other connection found, not moving"
      return
    end
    # puts "  no other connection"
    # il faut si l'objet est une person déconnecter le user éventuellement associé.
    if dependency.is_a? University::Person
      # puts "person, disconnecting from user"
      dependency.update_column :user_id, nil
    end
    # puts "connecting to #{new_university_id}"
    dependency.update_column :university_id, new_university_id
  end
end
