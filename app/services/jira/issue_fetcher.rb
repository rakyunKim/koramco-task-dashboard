module Jira
  class IssueFetcher
    def initialize(client = Client.new)
      @client = client
    end

    def my_open_issues(project_key: nil)
      jql = "statusCategory != Done"
      jql += " AND project = #{project_key}" if project_key
      jql += " ORDER BY updated DESC"

      result = @client.get("/search/jql", {
        jql: jql,
        fields: "summary,status,issuetype,project,assignee",
        maxResults: 50
      })

      result["issues"].map { |issue| normalize_issue(issue) }
    end

    def projects
      @client.get("/project").map { |p| { key: p["key"], name: p["name"] } }
    end

    def find(issue_key)
      data = @client.get("/issue/#{issue_key}")
      normalize_issue(data)
    end

    private

    def normalize_issue(data)
      fields = data["fields"]
      {
        id: data["id"],
        key: data["key"],
        summary: fields["summary"],
        status: fields.dig("status", "name"),
        status_category: fields.dig("status", "statusCategory", "key"),
        issue_type: fields.dig("issuetype", "name"),
        project_key: fields.dig("project", "key"),
        project_name: fields.dig("project", "name"),
        assignee_name: fields.dig("assignee", "displayName")
      }
    end
  end
end
