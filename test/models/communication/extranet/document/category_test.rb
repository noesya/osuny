# == Schema Information
#
# Table name: communication_extranet_document_categories
#
#  id            :uuid             not null, primary key
#  name          :string
#  slug          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  extranet_id   :uuid             not null, indexed
#  university_id :uuid             not null, indexed
#
# Indexes
#
#  extranet_document_categories_universities                        (university_id)
#  index_communication_extranet_document_categories_on_extranet_id  (extranet_id)
#
# Foreign Keys
#
#  fk_rails_6f2232d9f8  (university_id => universities.id)
#  fk_rails_76e327b90f  (extranet_id => communication_extranets.id)
#
require "test_helper"

class Communication::Extranet::Document::CategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end