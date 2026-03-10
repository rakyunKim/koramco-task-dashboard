module Webhooks
  class JiraController < ApplicationController
    skip_before_action :require_login
    skip_before_action :verify_authenticity_token

    before_action :verify_webhook_secret

    def receive
      event = JSON.parse(request.body.read)
      issue = event["issue"]
      return head :ok unless issue

      issue_key = issue["key"]
      status_category = issue.dig("fields", "status", "statusCategory", "key")

      if status_category == "done"
        task = Task.find_by(jira_issue_key: issue_key)
        if task && !task.completed?
          task.update!(completed: true, completed_at: Time.current, jira_synced_at: Time.current)

          JiraSyncLog.create!(
            direction: "jira_to_scoreboard",
            action: "complete",
            jira_issue_key: issue_key,
            task: task,
            status: "success"
          )
        end
      end

      head :ok
    rescue => e
      JiraSyncLog.create!(
        direction: "jira_to_scoreboard",
        action: "complete",
        jira_issue_key: issue_key,
        status: "failed",
        error_message: e.message
      )
      head :ok
    end

    private

    def verify_webhook_secret
      setting = JiraSetting.current
      return head :unauthorized unless setting&.webhook_secret.present?

      provided_secret = request.headers["X-Jira-Webhook-Secret"]
      unless ActiveSupport::SecurityUtils.secure_compare(setting.webhook_secret, provided_secret.to_s)
        head :unauthorized
      end
    end
  end
end
