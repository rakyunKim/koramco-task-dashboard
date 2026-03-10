class TasksController < ApplicationController
  def new
    @lead_measure = LeadMeasure.find(params[:lead_measure_id])
    @task = @lead_measure.tasks.new(
      week_start_date: Date.current.beginning_of_week(:monday)
    )
    @members = Member.ordered
    @lead_measures = @lead_measure.wig.lead_measures.current_week
  end

  def create
    selected_lm_id = task_params[:lead_measure_id].presence || params[:lead_measure_id]
    @lead_measure = LeadMeasure.find(selected_lm_id)
    @task = @lead_measure.tasks.new(task_params.except(:lead_measure_id))
    @task.week_start_date ||= Date.current.beginning_of_week(:monday)
    if @task.save
      redirect_to root_path, notice: "할 일이 추가되었습니다."
    else
      @members = Member.ordered
      @lead_measures = @lead_measure.wig.lead_measures.current_week
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @task = Task.find(params[:id])
    @lead_measure = @task.lead_measure
    @members = Member.ordered
    @lead_measures = @lead_measure.wig.lead_measures.current_week
  end

  def update
    @task = Task.find(params[:id])
    if @task.update(task_params)
      redirect_to root_path, notice: "할 일이 수정되었습니다."
    else
      @lead_measure = @task.lead_measure
      @members = Member.ordered
      @lead_measures = @lead_measure.wig.lead_measures.current_week
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    task = Task.find(params[:id])
    from_import = params[:source] == "import"
    task.destroy
    if from_import
      redirect_back fallback_location: import_tasks_path, notice: "할 일이 삭제되었습니다."
    else
      redirect_to root_path, notice: "할 일이 삭제되었습니다."
    end
  end

  def import_form
    @members = Member.ordered
    @member = Member.find(params[:member_id]) if params[:member_id].present?
    current_monday = Date.current.beginning_of_week(:monday)

    if @member
      past_lm_ids = @member.tasks
                           .where.not(week_start_date: current_monday)
                           .distinct
                           .pluck(:lead_measure_id)
      @past_lead_measures = LeadMeasure.where(id: past_lm_ids)
                                       .includes(:tasks)
                                       .order(week_start_date: :desc)

      if params[:lead_measure_id].present?
        @selected_lead_measure = LeadMeasure.find(params[:lead_measure_id])
        @past_tasks = @member.tasks.where(lead_measure: @selected_lead_measure)
      end
    end

    @current_lead_measures = Wig.active.first&.lead_measures&.where(week_start_date: current_monday) || LeadMeasure.none
  end

  def import_create
    current_monday = Date.current.beginning_of_week(:monday)
    task_ids = params[:task_ids] || []
    lead_measure_id = params[:lead_measure_id]

    return redirect_to import_tasks_path, alert: "작업을 선택해주세요." if lead_measure_id.blank?
    return redirect_to import_tasks_path, alert: "가져올 할 일을 선택해주세요." if task_ids.empty?

    count = 0
    ActiveRecord::Base.transaction do
      Task.where(id: task_ids).each do |past_task|
        Task.create!(
          title: past_task.title,
          member: past_task.member,
          lead_measure_id: lead_measure_id,
          contribution_value: past_task.contribution_value,
          week_start_date: current_monday,
          completed: false
        )
        count += 1
      end
    end

    redirect_to root_path, notice: "#{count}개 할 일을 가져왔습니다."
  end

  def toggle
    @task = Task.find(params[:id])
    @task.update!(
      completed: !@task.completed,
      completed_at: @task.completed? ? nil : Time.current
    )

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace(@task),
          turbo_stream.replace(
            "lead_measure_#{@task.lead_measure_id}",
            partial: "lead_measures/card",
            locals: { lead_measure: @task.lead_measure.reload }
          ),
          turbo_stream.replace(
            "wig_card",
            partial: "wigs/card",
            locals: { wig: @task.lead_measure.wig.reload }
          )
        ]
      }
      format.html { redirect_to root_path }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to root_path, alert: "상태 변경에 실패했습니다."
  end

  private

  def task_params
    params.require(:task).permit(:title, :member_id, :lead_measure_id, :week_start_date)
  end
end
