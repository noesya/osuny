class University::Person::Alumnus::Facets < FacetedSearch::Facets
  def initialize(params, options)
    super params

    @model = options[:model]
    @about = options[:about]

    filter_with_text :name, {
      title: University::Person.human_attribute_name('name')
    }

    filter_with_list :diploma_years, {
      source: @about.academic_years.ordered,
      title: Education::AcademicYear.model_name.human(count: 2),
      habtm: true
    }

    # TODO liste des formations (si about ≠ formation)
    # filter_with_list :programs, {
    #   source: @about.programs,
    #   habtm: true
    # }
  end
end
