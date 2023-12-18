# == Schema Information
#
# Table name: communication_website_agenda_categories
#
#  id                       :uuid             not null, primary key
#  featured_image_alt       :string
#  featured_image_credit    :text
#  meta_description         :text
#  name                     :string
#  path                     :string
#  position                 :integer
#  slug                     :string
#  summary                  :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  communication_website_id :uuid             not null, indexed
#  language_id              :uuid             not null, indexed
#  original_id              :uuid             indexed
#  university_id            :uuid             not null, indexed
#
# Indexes
#
#  idx_communication_website_agenda_cats_on_website_id             (communication_website_id)
#  index_communication_website_agenda_categories_on_language_id    (language_id)
#  index_communication_website_agenda_categories_on_original_id    (original_id)
#  index_communication_website_agenda_categories_on_university_id  (university_id)
#
# Foreign Keys
#
#  fk_rails_1e1b9fbf33  (original_id => communication_website_agenda_categories.id)
#  fk_rails_6cb9a4b8a1  (university_id => universities.id)
#  fk_rails_7b5ad84dda  (communication_website_id => communication_websites.id)
#  fk_rails_b0ddee638d  (language_id => languages.id)
#
require "test_helper"

class Communication::Website::Agenda::CategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
