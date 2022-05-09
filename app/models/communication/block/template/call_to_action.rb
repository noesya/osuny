class Communication::Block::Template::CallToAction < Communication::Block::Template
  def build_git_dependencies
    add_dependency image&.blob
  end

  def text
    "#{data['text']}"
  end

  def url
    "#{data['url']}"
  end

  def button
    "#{data['button']}"
  end

  def url_secondary
    "#{data['url_secondary']}"
  end

  def button_secondary
    "#{data['button_secondary']}"
  end

  def image
    image_with_alt
  end

  protected

  def image_with_alt
    blob = find_blob data, 'image'
    return if blob.nil?
    {
      blob: blob,
      alt: data['image_alt'],
      credit: data['image_credit']
    }.to_dot
  end
end
