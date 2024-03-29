class Extranet::Alumni::OrganizationsController < Extranet::Alumni::ApplicationController
  def index
    @facets = University::Organization::Facets.new params[:facets], {
      model: about&.university_person_alumni_organizations,
      about: about
    }
    @organizations = @facets.results
                      .ordered
                      .page(params[:page])
                      .per(60)
    @count = @organizations.total_count
    breadcrumb
  end

  def show
    @organization = about.university_person_alumni_organizations.find(params[:id])
    breadcrumb
  end

  protected

  def breadcrumb
    super
    add_breadcrumb University::Organization.model_name.human(count: 2), alumni_university_organizations_path
    add_breadcrumb @organization if @organization
  end
end
