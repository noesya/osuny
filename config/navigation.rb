SimpleNavigation::Configuration.run do |navigation|
  navigation.renderer = ::SimpleNavigation::BootstrapRenderer
  navigation.auto_highlight = true
  navigation.highlight_on_subpath = true
  navigation.selected_class = 'active'
  navigation.items do |primary|
    primary.item  :person,
                  University::Person::Alumnus.model_name.human(count: 2),
                  university_persons_path
    primary.item  :years,
                  Education::AcademicYear.model_name.human(count: 2),
                  education_academic_years_path
    primary.item  :cohorts,
                  Education::Cohort.model_name.human(count: 2),
                  education_cohorts_path
    primary.item  :organizations,
                  University::Organization.model_name.human(count: 2),
                  university_organizations_path
  end
end
