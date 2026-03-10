class JiraSyncCompletionJob < ApplicationJob
  queue_as :default
  retry_on Jira::RateLimitError, wait: :polynomially_longer, attempts: 3
  discard_on Jira::AuthenticationError

  def perform(task_id)
    task = Task.find_by(id: task_id)
    return unless task&.jira_linked? && task.completed?

    transitioner = Jira::IssueTransitioner.new
    transitioner.transition_to_dev(task.jira_issue_key)

    task.update!(jira_synced_at: Time.current)

    JiraSyncLog.create!(
      direction: "scoreboard_to_jira",
      action: "complete",
      jira_issue_key: task.jira_issue_key,
      task: task,
      status: "success"
    )
  rescue Jira::Error => e
    JiraSyncLog.create!(
      direction: "scoreboard_to_jira",
      action: "complete",
      jira_issue_key: task&.jira_issue_key,
      task: task,
      status: "failed",
      error_message: e.message
    )
    raise
  end
end
