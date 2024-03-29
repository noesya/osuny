class Admin::Research::ResearchersController < Admin::Research::ApplicationController
  before_action :load_researcher, except: :index

  has_scope :for_search_term

  def index
    @researchers = apply_scopes(current_university.people)
                    .for_language_id(current_university.default_language_id)
                    .researchers
                    .accessible_by(current_ability)
                    .ordered
                    .page(params[:page])
    breadcrumb
  end

  def show
    @papers = @researcher.research_journal_papers.ordered.page(params[:page])
    @hal_authors_with_same_name = Research::Hal::Author.import_from_hal @researcher.to_s
    @papers = @researcher.research_journal_papers.ordered.page(params[:page])
    breadcrumb
    add_breadcrumb @researcher
  end

  def sync_with_hal
    begin
      Research::Hal.pause_git_sync
      @researcher.import_research_hal_publications!
    ensure
      Research::Hal.unpause_git_sync
    end
    redirect_to admin_research_researcher_path(@researcher)
  end

  def update
    [
      :hal_doc_identifier,
      :hal_form_identifier,
      :hal_person_identifier
    ].each do |key|
      @researcher.update_column key, params[key] if params.has_key?(key)
    end
    redirect_to admin_research_researcher_path(@researcher)
  end

  protected

  def load_researcher
    @researcher = current_university.people
                                    .for_language_id(current_university.default_language_id)
                                    .researchers
                                    .accessible_by(current_ability)
                                    .find(params[:id])
  end

  def breadcrumb
    super
    add_breadcrumb University::Person::Researcher.model_name.human(count: 2), admin_research_researchers_path
  end

end
