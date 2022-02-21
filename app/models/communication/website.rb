# == Schema Information
#
# Table name: communication_websites
#
#  id                                :uuid             not null, primary key
#  about_type                        :string           indexed => [about_id]
#  access_token                      :string
#  git_provider                      :integer          default("github")
#  name                              :string
#  repository                        :string
#  static_pathname_administrators    :string           default("administrators")
#  static_pathname_authors           :string           default("authors")
#  static_pathname_posts             :string           default("posts")
#  static_pathname_programs          :string           default("programs")
#  static_pathname_research_articles :string           default("articles")
#  static_pathname_research_volumes  :string           default("volumes")
#  static_pathname_researchers       :string           default("researchers")
#  static_pathname_staff             :string           default("staff")
#  static_pathname_teachers          :string           default("teachers")
#  url                               :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  about_id                          :uuid             indexed => [about_type]
#  university_id                     :uuid             not null, indexed
#
# Indexes
#
#  index_communication_websites_on_about          (about_type,about_id)
#  index_communication_websites_on_university_id  (university_id)
#
# Foreign Keys
#
#  fk_rails_94b0abd85b  (university_id => universities.id)
#
class Communication::Website < ApplicationRecord
  include WithAbouts
  include WithGit
  include WithGitRepository
  include WithImport
  include WithIndexPages
  include WithMenuItems

  belongs_to :university

  scope :ordered, -> { order(:name) }

  enum git_provider: {
    github: 0,
    gitlab: 1
  }

  def to_s
    "#{name}"
  end

  def git_path(website)
    "data/website.yml"
  end

  def git_dependencies(website)
    dependencies = (
      [self] +
      pages + pages.map(&:active_storage_blobs).flatten +
      posts + posts.map(&:active_storage_blobs).flatten +
      [index_for(:home)] + index_for(:home).active_storage_blobs +
      [index_for(:communication_posts)] + index_for(:communication_posts).active_storage_blobs +
      [index_for(:persons)] + index_for(:persons).active_storage_blobs +
      [index_for(:authors)] + index_for(:authors).active_storage_blobs +
      people_with_facets + people.map(&:active_storage_blobs).flatten +
      categories + menus + [about]
    )

    if about.is_a? Education::School
      dependencies << index_for(:education_programs)
      dependencies += index_for(:education_programs).active_storage_blobs
      dependencies += about.programs
      dependencies += about.programs.map(&:active_storage_blobs).flatten
      dependencies << index_for(:administrators)
      dependencies += index_for(:administrators).active_storage_blobs
      dependencies << index_for(:teachers)
      dependencies += index_for(:teachers).active_storage_blobs
    elsif about.is_a? Research::Journal
      dependencies << index_for(:research_volumes)
      dependencies += index_for(:research_volumes).active_storage_blobs
      dependencies += about.volumes
      dependencies += about.volumes.map(&:active_storage_blobs).flatten
      dependencies << index_for(:research_articles)
      dependencies += index_for(:research_articles).active_storage_blobs
      dependencies += about.articles
      dependencies += about.articles.map(&:active_storage_blobs).flatten
      dependencies << index_for(:researchers)
      dependencies += index_for(:researchers).active_storage_blobs
    end

    dependencies
  end
end
