module Jira
  class IssueCreator
    def initialize(client = Client.new)
      @client = client
    end

    def create(project_key:, summary:, issue_type: "Task", description: nil)
      body = {
        fields: {
          project: { key: project_key },
          summary: summary,
          issuetype: { name: issue_type },
          description: description ? adf_text(description) : nil
        }.compact
      }

      result = @client.post("/issue", body)
      { id: result["id"], key: result["key"] }
    end

    private

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
