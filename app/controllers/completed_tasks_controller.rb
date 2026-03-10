class CompletedTasksController < ApplicationController
  def index
    @tasks = Task.where(completed: true)
                 .where.not(completed_at: nil)
                 .includes(:member, lead_measure: :wig)
                 .order(completed_at: :desc)

    if params[:member_id].present?
      @tasks = @tasks.where(member_id: params[:member_id])
    end

    @members = Member.ordered

    # Group by week (Monday), then by date
    @weeks = @tasks.group_by { |t| t.completed_at.to_date.beginning_of_week(:monday) }
    @weeks.each do |week, tasks|
      @weeks[week] = tasks.group_by { |t| t.completed_at.to_date }
    end
  end
end
