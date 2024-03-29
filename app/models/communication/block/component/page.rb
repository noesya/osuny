class Communication::Block::Component::Page < Communication::Block::Component::Base

  def page
    return unless website
    website.pages.published.find_by(id: data)
  end

  def dependencies
    [page]
  end

  def translate!
    return unless website && data.present?
    source_page = website.pages.find_by(id: data)
    @data = source_page.find_or_translate!(template.language).id if source_page.present?
  end

end
