class Communication::Block::Template
  attr_reader :block

  def initialize(block)
    @block = block
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

  def data
    unless @data
      initialize_data
      @data = block.data
    end
    @data
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

  def initialize_data
    block.data = {} unless block.data
    block.data['elements'] = [] unless block.data['elements']
  end

  def elements
    data.has_key?('elements') ? data['elements']
                              : []
  end

  def university
    block.university
  end
end
