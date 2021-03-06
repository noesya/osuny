class Communication::Block::Template
  attr_reader :block

  def initialize(block)
    @block = block
  end

  def sanitized_data
    data
  end

  def git_dependencies
    unless @git_dependencies
      @git_dependencies = []
      build_git_dependencies
      @git_dependencies.uniq!
    end
    @git_dependencies
  end

  def active_storage_blobs
    []
  end

  def allowed_for_about?
    template.allowed_for_about?
  end

  protected

  def build_git_dependencies
  end

  def add_dependency(dependency)
    if dependency.is_a? Array
      @git_dependencies += dependency
    else
      @git_dependencies += [dependency]
    end
  end

  def find_blob(object, key)
    id = object.dig(key, 'id')
    return if id.blank?
    university.active_storage_blobs.find id
  end

  def data
    block.data || {}
  end

  def elements
    data.has_key?('elements') ? data['elements']
                              : []
  end

  def exclude_for
    []
  end

  def university
    block.university
  end
end
