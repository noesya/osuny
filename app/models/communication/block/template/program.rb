class Communication::Block::Template::Program < Communication::Block::Template::Base

  has_elements

  def program
    program_id_component.program
  end

  def selected_programs
    @selected_programs ||= selected_programs_selection
  end

  def add_custom_git_dependencies
    selected_programs.each do |program|
      add_dependency program
      add_dependency program.active_storage_blobs.to_a
    end
  end

  protected

  def selected_programs_selection
    elements.map { |element| element.program }.compact
  end

end
