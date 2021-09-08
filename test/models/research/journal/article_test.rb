# == Schema Information
#
# Table name: research_journal_articles
#
#  id                         :uuid             not null, primary key
#  abstract                   :text
#  published_at               :date
#  references                 :text
#  text                       :text
#  title                      :string
#  created_at                 :datetime         not null
#  updated_at                 :date             not null
#  research_journal_id        :uuid             not null
#  research_journal_volume_id :uuid
#  university_id              :uuid             not null
#  updated_by_id              :uuid
#
# Indexes
#
#  index_research_journal_articles_on_research_journal_id         (research_journal_id)
#  index_research_journal_articles_on_research_journal_volume_id  (research_journal_volume_id)
#  index_research_journal_articles_on_university_id               (university_id)
#  index_research_journal_articles_on_updated_by_id               (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (research_journal_id => research_journals.id)
#  fk_rails_...  (research_journal_volume_id => research_journal_volumes.id)
#  fk_rails_...  (university_id => universities.id)
#  fk_rails_...  (updated_by_id => users.id)
#
require "test_helper"

class Research::Journal::ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
