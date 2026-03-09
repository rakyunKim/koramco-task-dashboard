class Member < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }

  def completed_tasks_count(week_start = nil)
    week_start ||= Date.current.beginning_of_week(:monday)
    tasks.where(completed: true, week_start_date: week_start).count
  end

  def total_tasks_count(week_start = nil)
    week_start ||= Date.current.beginning_of_week(:monday)
    tasks.where(week_start_date: week_start).count
  end
end
