class Task < ApplicationRecord
  belongs_to :lead_measure
  belongs_to :member

  validates :title, presence: true
  validates :week_start_date, presence: true

  scope :current_week, -> {
    monday = Date.current.beginning_of_week(:monday)
    where(week_start_date: monday)
  }
  scope :by_member, ->(member) { where(member: member) }

  after_save :update_lead_measure_value, if: :saved_change_to_completed?
  after_create :update_lead_measure_value, unless: :saved_change_to_completed?
  after_destroy :update_lead_measure_value

  delegate :name, to: :member, prefix: :assignee

  private

  def update_lead_measure_value
    lead_measure.recalculate_current_value!
  end
end
