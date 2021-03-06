get 'cohorts'           => 'extranet/cohorts#index', as: :education_cohorts
get 'cohorts/:id'       => 'extranet/cohorts#show', as: :education_cohort
get 'organizations'     => 'extranet/organizations#index', as: :university_organizations
get 'organizations/:id'  => 'extranet/organizations#show', as: :university_organization
get 'persons'           => 'extranet/persons#index', as: :university_persons
get 'persons/:id'       => 'extranet/persons#show', as: :university_person
get 'years'             => 'extranet/academic_years#index', as: :education_academic_years
get 'years/:id'         => 'extranet/academic_years#show', as: :education_academic_year
root to: 'extranet/home#index'
