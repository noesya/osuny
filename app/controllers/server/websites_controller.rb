class Server::WebsitesController < Server::ApplicationController
  before_action :load_websites, only: [:index, :manage_versions, :update_all_themes]
  before_action :load_website, except: [:index, :manage_versions, :update_all_themes]

  has_scope :for_theme_version
  has_scope :for_production
  has_scope :for_update
  has_scope :for_search_term
  has_scope :for_updatable_theme

  def index
    breadcrumb
  end

  def manage_versions
    @websites = @websites.with_repository.with_url
    load_filters
    breadcrumb
    add_breadcrumb "Gestion des versions"
  end

  def update_all_themes
    @websites.find_each do |website|
      website.clean_and_rebuild
    end
    redirect_back(fallback_location: manage_versions_server_websites_path, notice: t('server_admin.websites.update_all_themes_notice'))
  end

  def sync_theme_version
    @website.get_current_theme_version!
  end

  def update_theme
    @website.update_theme_version
  end

  def show
    breadcrumb
    add_breadcrumb @website
  end

  def update
    university_id = params.dig(:communication_website, :university_id)
    @website.move_to_university(university_id) if university_id
    redirect_to server_website_path(@website), notice: t('admin.successfully_updated_html', model: @website.to_s)
  end

  protected

  def breadcrumb
    super
    add_breadcrumb Communication::Website.model_name.human(count: 2), server_websites_path
  end

  def load_websites
    @websites = apply_scopes(Communication::Website.all).ordered
  end

  def load_website
    @website = Communication::Website.find params[:id]
  end
end
