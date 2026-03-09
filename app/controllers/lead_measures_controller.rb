class LeadMeasuresController < ApplicationController
  before_action :set_wig

  def new
    @lead_measure = @wig.lead_measures.new(
      week_start_date: Date.current.beginning_of_week(:monday)
    )
  end

  def create
    @lead_measure = @wig.lead_measures.new(lead_measure_params)
    @lead_measure.week_start_date ||= Date.current.beginning_of_week(:monday)
    if @lead_measure.save
      redirect_to root_path, notice: "선행지표가 추가되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @lead_measure = @wig.lead_measures.find(params[:id])
  end

  def update
    @lead_measure = @wig.lead_measures.find(params[:id])
    if @lead_measure.update(lead_measure_params)
      redirect_to root_path, notice: "선행지표가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    lm = @wig.lead_measures.find(params[:id])
    from_import = params[:source] == "import"
    current_monday = Date.current.beginning_of_week(:monday)

    if from_import && lm.week_start_date == current_monday
      redirect_back fallback_location: root_path, alert: "이번 주 선행지표는 여기서 삭제할 수 없습니다."
    else
      lm.destroy
      if from_import
        redirect_back fallback_location: import_tasks_path, notice: "선행지표와 관련 작업이 삭제되었습니다."
      else
        redirect_to root_path, notice: "선행지표가 삭제되었습니다."
      end
    end
  end

  private

  def set_wig
    @wig = Wig.find(params[:wig_id])
  end

  def lead_measure_params
    params.require(:lead_measure).permit(:title, :weekly_target, :week_start_date)
  end
end
