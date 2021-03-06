class Communication::Block::Component::Base
  include Accessible

  attr_reader :property, :template

  def initialize(property, template, options = nil)
    @property = property.to_s
    @template = template
    @options = options
  end

  def default_data
    ''
  end

  def data
    @data || default_data
  end

  def data=(value)
    @data = value
  end

  def kind
    self.class.name.demodulize.underscore
  end

  def git_dependencies
    []
  end

  def website
    template.block.about&.website
  end
end
