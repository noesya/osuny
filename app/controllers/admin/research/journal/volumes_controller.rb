class Admin::Research::Journal::VolumesController < Admin::Research::Journal::ApplicationController
  load_and_authorize_resource class: Research::Journal::Volume

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
    @journal = current_university.research_journals.find params[:journal_id]
    @volume.journal = @journal
    @volume.university = @journal.university
    if @volume.save
      redirect_to admin_research_journal_volume_path(@volume), notice: "Volume was successfully created."
    else
      breadcrumb
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @volume.update(volume_params)
      redirect_to admin_research_journal_volume_path(@volume), notice: "Volume was successfully updated."
    else
      breadcrumb
      render :edit, status: :unprocessable_entity
  end
  end

  def destroy
    @journal = @volume.journal
    @volume.destroy
    redirect_to admin_research_journal_path(@journal), notice: "Volume was successfully destroyed."
  end

  private

  def breadcrumb
    super
    add_breadcrumb Research::Journal::Volume.model_name.human(count: 2), admin_research_journal_volumes_path
    breadcrumb_for @volume
  end

  def volume_params
    params.require(:research_journal_volume).permit(:title, :number, :published_at)
  end
end
