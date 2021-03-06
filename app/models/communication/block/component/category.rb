class Communication::Block::Component::Category < Communication::Block::Component::Base

  def category
    return unless website
    website.categories.find_by(id: data)
  end

  def git_dependencies
    [category, category&.best_featured_image&.blob]
  end

end
