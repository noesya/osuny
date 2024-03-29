class Admin::Administration::Qualiopi::IndicatorsController < Admin::Administration::ApplicationController
  load_and_authorize_resource class: Administration::Qualiopi::Indicator

  def index
    breadcrumb
  end

  def show
    dir = "admin/administration/qualiopi/evaluations/"
    file = "#{dir}_criterion_#{@indicator.number}"
    file_exists = lookup_context.find_all(file).any? 
    @partial = "#{dir}criterion_#{@indicator.number}" if file_exists
    breadcrumb
  end

  protected

  def breadcrumb
    super
    add_breadcrumb Administration::Qualiopi.model_name.human(count: 2), admin_administration_qualiopi_criterions_path
    if @indicator
      add_breadcrumb @indicator.criterion, [:admin, @indicator.criterion]
      add_breadcrumb @indicator, [:admin, @indicator]
    end
  end

  def indicator_params
    params.require(:features_education_qualiopi_indicator)
          .permit(:criterion_id, :number, :name, :level_expected, :proof, :requirement, :non_conformity)
  end
end
