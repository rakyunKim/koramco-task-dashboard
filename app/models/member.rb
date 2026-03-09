class Member < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }

  def completed_tasks_count(week_start = nil)
    week_start ||= Date.current.beginning_of_week(:monday)
    if tasks.loaded?
      tasks.count { |t| t.completed? && t.week_start_date == week_start }
    else
      tasks.where(completed: true, week_start_date: week_start).count
    end
  end

  def total_tasks_count(week_start = nil)
    week_start ||= Date.current.beginning_of_week(:monday)
    if tasks.loaded?
      tasks.count { |t| t.week_start_date == week_start }
    else
      tasks.where(week_start_date: week_start).count
    end
  end
end
