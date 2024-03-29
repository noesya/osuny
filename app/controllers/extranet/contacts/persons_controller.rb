class Extranet::Contacts::PersonsController < Extranet::Contacts::ApplicationController
  def index
    @people = current_extranet.connected_people
                              .ordered
                              .page(params[:page])
                              .per(60)
    @count = @people.total_count
    breadcrumb
  end

  def show
    @person = current_extranet.connected_people.find(params[:id])
    @current_experiences = @person.experiences.includes(:organization).current.ordered
    breadcrumb
  end

  protected

  def breadcrumb
    super
    add_breadcrumb University::Person.model_name.human(count: 2), contacts_university_persons_path
    add_breadcrumb @person if @person
  end
end
