module Jira
  class ImportService
    def import(issues:, lead_measure:, member:)
      imported = []

      ActiveRecord::Base.transaction do
        issues.each do |issue|
          next if Task.exists?(jira_issue_key: issue[:key])

          task = Task.create!(
            lead_measure: lead_measure,
            member: member,
            title: "[#{issue[:key]}] #{issue[:summary]}",
            jira_issue_key: issue[:key],
            jira_issue_id: issue[:id],
            jira_synced_at: Time.current,
            week_start_date: Date.current.beginning_of_week(:monday),
            completed: false
          )

          imported << task

          JiraSyncLog.create!(
            direction: "jira_to_scoreboard",
            action: "import",
            jira_issue_key: issue[:key],
            task: task,
            status: "success"
          )
        end
      end

      imported
    end
  end
end
