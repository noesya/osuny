# == Schema Information
#
# Table name: communication_website_imported_pages
#
#  id                 :uuid             not null, primary key
#  content            :text
#  data               :jsonb
#  excerpt            :text
#  identifier         :string           indexed
#  parent             :string
#  path               :text
#  slug               :text
#  status             :integer          default(0)
#  title              :string
#  url                :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  featured_medium_id :uuid             indexed
#  page_id            :uuid             indexed
#  university_id      :uuid             not null, indexed
#  website_id         :uuid             not null, indexed
#
# Indexes
#
#  idx_communication_website_imported_pages_on_featured_medium_id  (featured_medium_id)
#  index_communication_website_imported_pages_on_identifier        (identifier)
#  index_communication_website_imported_pages_on_page_id           (page_id)
#  index_communication_website_imported_pages_on_university_id     (university_id)
#  index_communication_website_imported_pages_on_website_id        (website_id)
#
# Foreign Keys
#
#  fk_rails_aa3ad9c6c8  (website_id => communication_website_imported_websites.id)
#  fk_rails_df500f96c3  (page_id => communication_website_pages.id)
#  fk_rails_e47b76ff30  (university_id => universities.id)
#  fk_rails_e582fbdc5c  (featured_medium_id => communication_website_imported_media.id)
#
class Communication::Website::Imported::Page < ApplicationRecord
  include WithUniversity
  include Communication::Website::Imported::WithRichText

  belongs_to :website,
             class_name: 'Communication::Website::Imported::Website'
  belongs_to :page,
             class_name: 'Communication::Website::Page',
             optional: true
  alias_attribute :generated_object, :page
  belongs_to :featured_medium,
             class_name: 'Communication::Website::Imported::Medium',
             optional: true

  before_validation :sync
  after_commit :sync_attachments, on: [:create, :update]

  default_scope { order(:path) }

  def data=(value)
    super value
    self.url = value['link']
    self.slug = value['slug']
    self.title = value['title']['rendered']
    self.excerpt = value['excerpt']['rendered']
    self.content = value['content']['rendered']
    self.parent = value['parent']
    self.featured_medium = website.media.find_by(identifier: value['featured_media']) unless value['featured_media'] == 0
    self.created_at = value['date_gmt']
    self.updated_at = value['modified_gmt']
  end

  def to_s
    "#{title}"
  end

  protected

  def sync
    if page.nil?
      self.page = Communication::Website::Page.new  university: university,
                                                    website: website.website, # Real website, not imported website
                                                    slug: path
      self.page.title = "Untitled"
      self.page.save
    else
      # Continue only if there are remote changes
      # Don't touch if there are local changes (page.updated_at > updated_at)
      # Don't touch if there are no remote changes (page.updated_at == updated_at)
      return unless ENV['APPLICATION_ENV'] == 'development' || updated_at > page.updated_at
    end
    puts "Update page #{page.id}"
    sanitized_title = Wordpress.clean_string self.title.to_s
    page.title = sanitized_title unless sanitized_title.blank? # If there is no title, leave it with "Untitled"
    page.slug = slug
    page.description = Wordpress.clean_string excerpt.to_s
    page.text = Wordpress.clean_html content.to_s
    page.published = true
    page.save
  end

  def sync_attachments
    return unless ENV['APPLICATION_ENV'] == 'development' || updated_at > page.updated_at
    if featured_medium.present?
      unless featured_medium.file.attached?
        featured_medium.load_remote_file!
        featured_medium.save
      end
      page.featured_image.attach(
        io: URI.open(featured_medium.file.blob.url),
        filename: featured_medium.file.blob.filename,
        content_type: featured_medium.file.blob.content_type
      )
    else
      fragment = Nokogiri::HTML.fragment(page.text.to_s)
      image = fragment.css('img').first
      if image.present?
        begin
          url = image.attr('src')
          download_service = DownloadService.download(url)
          page.featured_image.attach(download_service.attachable_data)
          image.remove
          page.update(text: fragment.to_html)
        rescue
        end
      end
    end
    page.update(text: rich_text_with_attachments(page.text.to_s))
  end
end
