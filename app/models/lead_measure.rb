class LeadMeasure < ApplicationRecord
  belongs_to :wig
  has_many :tasks, dependent: :destroy

  validates :title, presence: true
  validates :week_start_date, presence: true

  scope :current_week, -> {
    monday = Date.current.beginning_of_week(:monday)
    where(week_start_date: monday)
  }

  def total_tasks_count
    if tasks.loaded?
      tasks.count { |t| t.week_start_date == week_start_date }
    else
      tasks.where(week_start_date: week_start_date).count
    end
  end

  def completed_tasks_count
    if tasks.loaded?
      tasks.count { |t| t.completed? && t.week_start_date == week_start_date }
    else
      tasks.where(completed: true, week_start_date: week_start_date).count
    end
  end

  def progress_percentage
    total = total_tasks_count
    return 0 if total.zero?
    (completed_tasks_count.to_f / total * 100).round(1)
  end

  def completed?
    total_tasks_count > 0 && completed_tasks_count == total_tasks_count
  end

  def progress_color
    pct = progress_percentage
    if pct >= 70 then "green"
    elsif pct >= 40 then "yellow"
    else "red"
    end
  end

  def recalculate_current_value!
    update!(
      current_value: completed_tasks_count,
      weekly_target: [total_tasks_count, 1].max
    )
    wig.recalculate!
  end
end
