class Communication::Block::Component::AgendaCategory < Communication::Block::Component::Base

  def category
    return unless website
    website.agenda_categories.find_by(id: data)
  end

  def dependencies
    [category]
  end

  def translate!
    return unless category.present?
    @data = category.find_or_translate!(template.language).id
  end

end
