class Server::UniversitiesController < Server::ApplicationController
  load_and_authorize_resource

  def index
    breadcrumb
  end

  def show
    breadcrumb
  end

  def new
    breadcrumb
  end

  def edit
    breadcrumb
    add_breadcrumb t('edit')
  end

  def create
    if @university.save
      redirect_to [:server, @university], notice: t('admin.successfully_created_html', model: @university.to_s)
    else
      breadcrumb
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @university.update(university_params)
      redirect_to [:server, @university], notice: t('admin.successfully_updated_html', model: @university.to_s)
    else
      breadcrumb
      add_breadcrumb t('edit')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @university.destroy
    redirect_to server_universities_url, notice: t('admin.successfully_destroyed_html', model: @university.to_s)
  end

  protected

  def breadcrumb
    super
    add_breadcrumb University.model_name.human(count: 2), server_universities_path
    if @university
      if @university.persisted?
        add_breadcrumb @university, [:server, @university]
      else
        add_breadcrumb t('create')
      end
    end
  end

  def university_params
    params.require(:university).permit(:name, :address, :zipcode, :city, :country, :private, :identifier, :logo, :logo_delete, :sms_sender_name)
  end
end
