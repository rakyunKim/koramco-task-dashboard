class LeadMeasuresController < ApplicationController
  before_action :set_wig, except: [:move_to_current_week]

  def new
    @lead_measure = @wig.lead_measures.new(
      week_start_date: Date.current.beginning_of_week(:monday)
    )
  end

  def create
    @lead_measure = @wig.lead_measures.new(lead_measure_params)
    @lead_measure.week_start_date ||= Date.current.beginning_of_week(:monday)
    if @lead_measure.save
      redirect_to root_path, notice: "작업이 추가되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @lead_measure = @wig.lead_measures.find(params[:id])
  end

  def update
    @lead_measure = @wig.lead_measures.find(params[:id])
    week_changed = lead_measure_params[:week_start_date].present? &&
                   lead_measure_params[:week_start_date].to_s != @lead_measure.week_start_date.to_s
    if @lead_measure.update(lead_measure_params)
      if week_changed
        @lead_measure.tasks.update_all(week_start_date: @lead_measure.week_start_date)
        @lead_measure.recalculate_current_value!
      end
      redirect_to root_path, notice: "작업이 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    lm = @wig.lead_measures.find(params[:id])
    from_import = params[:source] == "import"
    current_monday = Date.current.beginning_of_week(:monday)

    if from_import && lm.week_start_date == current_monday
      redirect_back fallback_location: root_path, alert: "이번 주 작업은 여기서 삭제할 수 없습니다."
    else
      lm.destroy
      if from_import
        redirect_back fallback_location: import_tasks_path, notice: "작업과 관련 할 일이 삭제되었습니다."
      else
        redirect_to root_path, notice: "작업이 삭제되었습니다."
      end
    end
  end

  def move_to_current_week
    wig = Wig.active.first!
    lm = wig.lead_measures.find(params[:id])
    current_monday = Date.current.beginning_of_week(:monday)
    lm.update!(week_start_date: current_monday)
    lm.tasks.update_all(week_start_date: current_monday)
    lm.recalculate_current_value!
    redirect_to root_path, notice: "작업이 이번 주로 이동되었습니다."
  end

  private

  def set_wig
    @wig = Wig.find(params[:wig_id])
  end

  def lead_measure_params
    params.require(:lead_measure).permit(:title, :weekly_target, :week_start_date)
  end
end
