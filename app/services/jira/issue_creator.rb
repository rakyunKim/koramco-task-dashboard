module Jira
  class IssueCreator
    def initialize(client = Client.new)
      @client = client
    end

    def create(project_key:, summary:, issue_type: nil, description: nil, assignee_name: nil)
      fields = {
        project: { key: project_key },
        summary: summary,
        issuetype: { id: issue_type || default_issue_type_id(project_key) },
        description: description ? adf_text(description) : nil
      }.compact

      if assignee_name.present?
        account_id = find_assignee_account_id(assignee_name)
        fields[:assignee] = { accountId: account_id } if account_id
      end

      result = @client.post("/issue", { fields: fields })
      issue_key = result["key"]

      transition_to_in_progress(issue_key)

      { id: result["id"], key: issue_key }
    end

    private

    def find_assignee_account_id(name)
      users = @client.get("/user/search", { query: name, maxResults: 5 })
      match = users&.find { |u| u["displayName"]&.include?(name) }
      match&.dig("accountId")
    rescue Jira::Error
      nil
    end

    def transition_to_in_progress(issue_key)
      transitions = @client.get("/issue/#{issue_key}/transitions")
      in_progress = transitions["transitions"]&.find { |t| t.dig("to", "name") == "진행 중" }
      return unless in_progress

      @client.post("/issue/#{issue_key}/transitions", { transition: { id: in_progress["id"] } })
    rescue Jira::Error
      # 전환 실패해도 이슈 생성 자체는 성공으로 처리
    end

    def default_issue_type_id(project_key)
      types = @client.get("/issue/createmeta/#{project_key}/issuetypes")
      task_type = types["issueTypes"]&.find { |t| t["name"].in?(["Task", "작업"]) }
      task_type&.dig("id") || types.dig("issueTypes", 0, "id")
    end

    def adf_text(text)
      {
        type: "doc",
        version: 1,
        content: [
          {
            type: "paragraph",
            content: [ { type: "text", text: text } ]
          }
        ]
      }
    end
  end
end
