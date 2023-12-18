# == Schema Information
#
# Table name: communication_website_agenda_events
#
#  id                       :uuid             not null, primary key
#  featured_image_alt       :text
#  featured_image_credit    :text
#  from_day                 :date
#  from_hour                :time
#  meta_description         :text
#  published                :boolean          default(FALSE)
#  slug                     :string           indexed
#  subtitle                 :string
#  summary                  :text
#  title                    :string
#  to_day                   :date
#  to_hour                  :time
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  communication_website_id :uuid             not null, indexed
#  language_id              :uuid             not null, indexed
#  original_id              :uuid             indexed
#  parent_id                :uuid             indexed
#  university_id            :uuid             not null, indexed
#
# Indexes
#
#  index_agenda_events_on_communication_website_id             (communication_website_id)
#  index_communication_website_agenda_events_on_language_id    (language_id)
#  index_communication_website_agenda_events_on_original_id    (original_id)
#  index_communication_website_agenda_events_on_parent_id      (parent_id)
#  index_communication_website_agenda_events_on_slug           (slug)
#  index_communication_website_agenda_events_on_university_id  (university_id)
#
# Foreign Keys
#
#  fk_rails_00ca585c35  (university_id => universities.id)
#  fk_rails_5fa53206f2  (communication_website_id => communication_websites.id)
#  fk_rails_67834f0062  (language_id => languages.id)
#  fk_rails_917095d5ca  (parent_id => communication_website_agenda_events.id)
#  fk_rails_fc3fea77c2  (original_id => communication_website_agenda_events.id)
#
class Communication::Website::Agenda::Event < ApplicationRecord
  include AsDirectObject
  include Contentful
  include Sanitizable
  include WithAccessibility
  include WithBlobs
  include WithDuplication
  include WithFeaturedImage
  include WithMenuItemTarget
  include WithPermalink
  include WithSlug
  include WithTranslations
  include WithTree
  include WithUniversity

  belongs_to  :parent,
              class_name: 'Communication::Website::Agenda::Event',
              optional: true

  has_and_belongs_to_many :categories,
                          class_name: 'Communication::Website::Agenda::Category',
                          join_table: :communication_website_agenda_events_categories,
                          foreign_key: :communication_website_agenda_event_id,
                          association_foreign_key: :communication_website_agenda_category_id

  scope :ordered_desc, -> { order(from_day: :desc, from_hour: :desc) }
  scope :ordered_asc, -> { order(:from_day, :from_hour) }
  scope :ordered, -> { ordered_asc }
  scope :recent, -> { order(:updated_at).limit(5) }
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }

  scope :for_category, -> (category_id) { joins(:categories).where(communication_website_categories: { id: category_id }).distinct }

  scope :future, -> { where('from_day > :today', today: Date.today).ordered_asc }
  scope :future_or_current, -> { where('from_day >= :today', today: Date.today).ordered_asc }
  scope :current, -> { where('(from_day <= :today AND to_day IS NULL) OR (from_day <= :today AND to_day >= :today)', today: Date.today).ordered_asc }
  scope :archive, -> { where('to_day < :today', today: Date.today).ordered_desc }
  scope :past, -> { archive }

  validates_presence_of :from_day, :title
  validate :to_day_after_from_day, :to_hour_after_from_hour_on_same_day

  STATUS_FUTURE = 'future'
  STATUS_CURRENT = 'current'
  STATUS_ARCHIVE = 'archive'

  def status
    if future?
      STATUS_FUTURE
    elsif current?
      STATUS_CURRENT
    else
      STATUS_ARCHIVE
    end
  end

  def future?
    from_day > Date.today
  end

  def current?
    to_day.present? ? (Date.today >= from_day && Date.today <= to_day)
                    : from_day <= Date.today # Les événements sans date de fin restent actifs
  end

  def archive?
    to_day.present? ? to_day < Date.today
                    : false # Les événements sans date de fin restent actifs
  end

  # Un événement demain aura une distance de 1, comme un événement hier
  # On utilise cette info pour classer les événements à venir dans un sens et les archives dans l'autre
  def distance_in_days
    (Date.today - from_day).to_i.abs
  end

  def git_path(website)
    return unless website.id == communication_website_id && published
    path = "#{git_path_content_prefix(website)}events/"
    path += "archives/#{from_day.year}/" if archive?
    path += "#{from_day.strftime "%Y-%m-%d"}-#{slug}.html"
    path
  end

  def template_static
    "admin/communication/websites/agenda/events/static"
  end

  def dependencies
    active_storage_blobs +
    contents_dependencies +
    [website.config_default_content_security_policy]
  end

  def references
    menus +
    abouts_with_agenda_block
  end

  def url
    return unless published
    return if website.url.blank?
    return if website.special_page(Communication::Website::Page::CommunicationAgenda)&.path.blank?
    return if current_permalink_in_website(website).blank?
    "#{Static.remove_trailing_slash website.url}#{Static.clean_path current_permalink_in_website(website).path}"
  end

  def to_s
    "#{title}"
  end

  protected

  def check_accessibility
    accessibility_merge_array blocks
  end

  def to_day_after_from_day
    errors.add(:to_day, :too_soon) if to_day.present? && to_day < from_day
  end

  def to_hour_after_from_hour_on_same_day
    return if from_day != to_day
    errors.add(:to_hour, :too_soon) if to_hour.present? && from_hour.present? && to_hour < from_hour
  end

  def explicit_blob_ids
    super.concat [featured_image&.blob_id]
  end

  def abouts_with_agenda_block
    website.blocks.agenda.collect(&:about)
  end
end
