class Admin::Communication::WebsitesController < Admin::Communication::ApplicationController
  load_and_authorize_resource class: Communication::Website

  def index
    @websites = current_university.communication_websites
    breadcrumb
  end

  def show
    breadcrumb
  end

  def new
    breadcrumb
  end

  def import
    if request.post?
      @website.import!
      flash[:notice] = t('communication.website.imported.launched')
    end
    @imported_website = @website.imported_website
    @imported_pages = @imported_website.pages.page params[:pages_page]
    @imported_posts = @imported_website.posts.page params[:posts_page]
    breadcrumb
    add_breadcrumb Communication::Website::Imported::Website.model_name.human
  end

  def edit
    breadcrumb
    add_breadcrumb t('edit')
  end

  def create
    @website.university = current_university
    if @website.save
      redirect_to [:admin, @website], notice: "Site was successfully created."
    else
      breadcrumb
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @website.update(website_params)
      redirect_to [:admin, @website], notice: "Site was successfully updated."
    else
      breadcrumb
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @website.destroy
    redirect_to admin_communication_websites_url, notice: "Site was successfully destroyed."
  end

  protected

  def breadcrumb
    super
    add_breadcrumb Communication::Website.model_name.human(count: 2), admin_communication_websites_path
    breadcrumb_for @website
  end

  def website_params
    params.require(:communication_website).permit(:name, :domain, :repository, :access_token, :about_type, :about_id)
  end
end
