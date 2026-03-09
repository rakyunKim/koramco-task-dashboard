class DashboardController < ApplicationController
  def show
    @wig = Wig.active.includes(lead_measures: :tasks).first
    if @wig
      monday = Date.current.beginning_of_week(:monday)
      @lead_measures = @wig.lead_measures
                           .select { |lm| lm.week_start_date == monday }
                           .sort_by(&:created_at)
      @tasks_by_member = Task.current_week
                             .includes(:member, :lead_measure)
                             .joins(:lead_measure)
                             .where(lead_measures: { wig_id: @wig.id })
                             .order(:created_at)
                             .group_by(&:member)
                             .sort_by { |member, _| member.name }

      # Weekly progress stats
      current_tasks = Task.current_week.joins(:lead_measure).where(lead_measures: { wig_id: @wig.id })
      @weekly_total_tasks = current_tasks.count
      @weekly_completed_tasks = current_tasks.where(completed: true).count

      # Upcoming lead measures (future weeks)
      @upcoming_lead_measures = @wig.lead_measures
                                    .where("week_start_date > ?", monday)
                                    .includes(:tasks)
                                    .order(:week_start_date, :created_at)
    end
    @members = Member.ordered
  end
end
