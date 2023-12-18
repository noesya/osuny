class Communication::Block::Template::Timeline < Communication::Block::Template::Base

  has_elements
  has_layouts [:vertical, :horizontal]

  def children
    elements
  end
end
