# == Schema Information
#
# Table name: university_organizations
#
#  id                 :uuid             not null, primary key
#  active             :boolean          default(TRUE)
#  address            :string
#  address_additional :string
#  address_name       :string
#  city               :string
#  country            :string
#  email              :string
#  kind               :integer          default("company")
#  latitude           :float
#  linkedin           :string
#  long_name          :string
#  longitude          :float
#  mastodon           :string
#  meta_description   :text
#  name               :string
#  nic                :string
#  phone              :string
#  siren              :string
#  slug               :string           indexed
#  summary            :text
#  text               :text
#  twitter            :string
#  url                :string
#  zipcode            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  language_id        :uuid             indexed
#  original_id        :uuid             indexed
#  university_id      :uuid             not null, indexed
#
# Indexes
#
#  index_university_organizations_on_language_id    (language_id)
#  index_university_organizations_on_original_id    (original_id)
#  index_university_organizations_on_slug           (slug)
#  index_university_organizations_on_university_id  (university_id)
#
# Foreign Keys
#
#  fk_rails_35fcd198e0  (university_id => universities.id)
#  fk_rails_3a9208fa29  (language_id => languages.id)
#  fk_rails_5af11ea0cc  (original_id => university_organizations.id)
#
require "test_helper"

class University::OrganizationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
