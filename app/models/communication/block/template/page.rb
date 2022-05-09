class Communication::Block::Template::Page < Communication::Block::Template
  def build_git_dependencies
    add_dependency main_page
    selected_pages.each do |hash|
      page = hash.page
      add_dependency page
      add_dependency page.active_storage_blobs
    end
  end

  def selected_pages
    @selected_pages ||= elements.map { |element|
      p = page(element['id'])
      next if p.nil?
      hash_from_page(p, element)
    }.compact
  end

  def main_page
    @main_page ||= page(data['page_id'])
  end

  def show_description
    data['show_description'] || false
  end

  def show_image
    data['show_image'] || false
  end

  protected

  def hash_from_page(page, element)
    {
      page: page,
      show_description: element['show_description'] || false,
      show_image: element['show_image'] || false
    }.to_dot
  end

  def page(id)
    return if id.blank?
    page = block.about&.website
                       .pages
                       .published
                       .find_by(id: id)
  end
end
