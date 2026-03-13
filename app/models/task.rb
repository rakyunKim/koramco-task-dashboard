class Task < ApplicationRecord
  belongs_to :lead_measure
  belongs_to :member
  has_many :jira_sync_logs, dependent: :destroy

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

  # 지난 주 미완료 태스크를 현재 주로 이월
  def self.rollover_incomplete!
    current_monday = Date.current.beginning_of_week(:monday)
    incomplete_tasks = where(completed: false)
                         .where("week_start_date < ?", current_monday)
                         .includes(:lead_measure)

    return if incomplete_tasks.empty?

    ActiveRecord::Base.transaction do
      # lead_measure별로 그룹핑하여 현재 주 lead_measure 찾거나 생성
      lm_mapping = {}
      incomplete_tasks.group_by(&:lead_measure).each do |old_lm, _tasks|
        current_lm = LeadMeasure.find_or_create_by!(
          wig_id: old_lm.wig_id,
          title: old_lm.title,
          week_start_date: current_monday
        ) do |lm|
          lm.weekly_target = old_lm.weekly_target
          lm.unit = old_lm.unit
        end
        lm_mapping[old_lm.id] = current_lm
      end

      # 태스크 이동
      incomplete_tasks.each do |task|
        current_lm = lm_mapping[task.lead_measure_id]
        task.update_columns(
          lead_measure_id: current_lm.id,
          week_start_date: current_monday
        )
      end

      # lead_measure 값 재계산
      lm_mapping.values.uniq.each(&:recalculate_current_value!)
    end
  end

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
