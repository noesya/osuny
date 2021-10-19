# == Schema Information
#
# Table name: communication_website_imported_posts
#
#  id            :uuid             not null, primary key
#  content       :text
#  data          :jsonb
#  excerpt       :text
#  identifier    :string
#  path          :text
#  published_at  :datetime
#  slug          :text
#  status        :integer          default(0)
#  title         :string
#  url           :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  post_id       :uuid             not null
#  university_id :uuid             not null
#  website_id    :uuid             not null
#
# Indexes
#
#  index_communication_website_imported_posts_on_post_id        (post_id)
#  index_communication_website_imported_posts_on_university_id  (university_id)
#  index_communication_website_imported_posts_on_website_id     (website_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => communication_website_posts.id)
#  fk_rails_...  (university_id => universities.id)
#  fk_rails_...  (website_id => communication_website_imported_websites.id)
#
class Communication::Website::Imported::Post < ApplicationRecord
  belongs_to :university
  belongs_to :website,
             class_name: 'Communication::Website::Imported::Website'
  belongs_to :post,
             class_name: 'Communication::Website::Post',
             optional: true

  before_validation :sync

  default_scope { order(path: :desc) }

  def data=(value)
    super value
    self.url = value['link']
    self.slug = value['slug']
    self.path = URI(self.url).path
    self.title = value['title']['rendered']
    self.excerpt = value['excerpt']['rendered']
    self.content = value['content']['rendered']
    self.published_at = value['date']
  end

  def to_s
    "#{title}"
  end

  protected

  def sync
    if post.nil?
      self.post = Communication::Website::Post.new university: university,
                                                   website: website.website # Real website, not imported website
      self.post.title = "Untitled" # No title yet
      self.post.save
    end
    # TODO only if not modified since import
    post.title = Wordpress.clean title.to_s
    post.slug = slug
    post.description = Wordpress.clean excerpt.to_s
    post.text = Wordpress.clean content.to_s
    post.published_at = published_at if published_at
    post.save
  end
end
