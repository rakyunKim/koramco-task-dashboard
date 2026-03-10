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
  scope :jira_linked,   -> { where.not(jira_issue_key: nil) }
  scope :jira_unlinked, -> { where(jira_issue_key: nil) }

  after_save :update_lead_measure_value, if: :saved_change_to_completed?
  after_create :update_lead_measure_value, unless: :saved_change_to_completed?
  after_destroy :update_lead_measure_value
  after_commit :sync_completion_to_jira, if: :jira_linked_and_completed?

  delegate :name, to: :member, prefix: :assignee

  def jira_linked?
    jira_issue_key.present?
  end

  def jira_url
    return unless jira_linked?
    setting = JiraSetting.current
    return unless setting
    "#{setting.site_url}/browse/#{jira_issue_key}"
  end

  private

  def update_lead_measure_value
    lead_measure.recalculate_current_value!
  end

  def jira_linked_and_completed?
    jira_linked? && saved_change_to_completed? && completed?
  end

  def sync_completion_to_jira
    JiraSyncCompletionJob.perform_later(id)
  end
end
