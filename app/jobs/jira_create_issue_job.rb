class JiraCreateIssueJob < ApplicationJob
  queue_as :default
  retry_on Jira::RateLimitError, wait: :polynomially_longer, attempts: 3

  def perform(task_id, project_key)
    task = Task.find_by(id: task_id)
    return unless task && !task.jira_linked?

    creator = Jira::IssueCreator.new
    result = creator.create(
      project_key: project_key,
      summary: task.title,
      issue_type: "Task"
    )

    task.update!(
      jira_issue_key: result[:key],
      jira_issue_id: result[:id],
      jira_synced_at: Time.current
    )

    JiraSyncLog.create!(
      direction: "scoreboard_to_jira",
      action: "create",
      jira_issue_key: result[:key],
      task: task,
      status: "success"
    )
  rescue Jira::Error => e
    JiraSyncLog.create!(
      direction: "scoreboard_to_jira",
      action: "create",
      task: task,
      status: "failed",
      error_message: e.message
    )
    raise
  end
end
