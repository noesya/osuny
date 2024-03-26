class Communication::Block::Template::Post < Communication::Block::Template::Base

  has_elements
  has_layouts [
    :grid,
    :list,
    :highlight,
    :alternate,
    :large,
    :carousel
  ]
  has_component :mode, :option, options: [
    :all, 
    :category, 
    :selection,
    :categories
  ]
  has_component :posts_quantity, :number, options: 3
  has_component :category_id, :post_category
  has_component :hide_image, :boolean
  has_component :hide_summary, :boolean
  has_component :hide_category, :boolean
  has_component :hide_author, :boolean
  has_component :hide_date, :boolean

  def category
    category_id_component.category
  end

  def dependencies
    selected_posts
  end

  def selected_posts
    @selected_posts ||= send "selected_posts_#{mode}"
  end

  def allowed_for_about?
    !website.nil?
  end
  
  def children
    selected_posts
  end

  protected

  def selected_posts_all
    block.about&.website
                .posts
                .for_language(block.language)
                .published
                .ordered
                .limit(posts_quantity)
  end

  def selected_posts_category
    return [] if category.nil?
    category_ids = [category.id, category.descendants.map(&:id)].flatten
    university.communication_website_posts.for_language(block.language)
                                          .joins(:categories)
                                          .where(categories: { id: category_ids })
                                          .distinct
                                          .published
                                          .ordered
                                          .limit(posts_quantity)
  end

  def selected_posts_selection
    elements.map { |element|
      post(element.id)
    }.compact
  end

  def selected_posts_categories
    []
  end

  def post(id)
    return if id.blank?
    block.about&.website
                .posts
                .for_language(block.language)
                .published
                .find_by(id: id)
  end
end
