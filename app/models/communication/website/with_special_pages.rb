module Communication::Website::WithSpecialPages
  extend ActiveSupport::Concern

  included do

    after_create :create_missing_special_pages
    after_touch :create_missing_special_pages, :manage_special_pages_publication

    def special_page(kind)
      pages.where(kind: kind).first
    end

    def create_missing_special_pages
      homepage = create_special_page('home')
      # first level pages with test
      ['legal_terms', 'sitemap', 'privacy_policy', 'accessibility', 'communication_posts', 'education_programs', 'education_diplomas', 'research_articles', 'research_volumes', 'organizations'].each do |kind|
        create_special_page(kind, homepage.id) if public_send("has_#{kind}?")
      end
      # team pages
      if has_persons?
        persons = create_special_page('persons', homepage.id)
        ['administrators', 'authors', 'researchers', 'teachers'].each do |kind|
          create_special_page(kind, persons.id) if public_send("has_#{kind}?")
        end
      end
    end

    def manage_special_pages_publication
      special_pages_keys.each do |kind|
        published = public_send("has_#{kind}?")
        special_page(kind).update(published: published)
      end
    end

  end

  private

  def create_special_page(kind, parent_id = nil)
    i18n_key = "communication.website.pages.defaults.#{kind}"
    page = pages.where(kind: kind).first_or_initialize(
      title: I18n.t("#{i18n_key}.title"),
      slug: I18n.t("#{i18n_key}.slug"),
      description_short: I18n.t("#{i18n_key}.description_short"),
      parent_id: parent_id,
      published: true,
      university_id: university_id
    )
    if page.new_record?
      page.save_and_sync
    end
    page
  end

  def special_pages_keys
    @special_pages_keys ||= pages.where.not(kind: nil).pluck(:kind).uniq
  end


end
