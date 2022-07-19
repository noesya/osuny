class Communication::Block::Template::Program::Element < Communication::Block::Template::Base

  has_component :id, :program

  def program
    id_component.program
  end
end
