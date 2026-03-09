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
    end
    @members = Member.ordered
  end
end
