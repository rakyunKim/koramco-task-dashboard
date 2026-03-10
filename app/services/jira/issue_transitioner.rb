module Jira
  class IssueTransitioner
    def initialize(client = Client.new)
      @client = client
    end

    def transition_to_done(issue_key)
      transition_to(issue_key, "done")
    end

    def transition_to_dev(issue_key)
      transition_to(issue_key, "DEV 반영")
    end

    private

    def transition_to(issue_key, target)
      transitions = @client.get("/issue/#{issue_key}/transitions")

      found = if target == "done"
        transitions["transitions"].find { |t| t.dig("to", "statusCategory", "key") == "done" }
      else
        transitions["transitions"].find { |t| t.dig("to", "name") == target }
      end

      raise Jira::Error, "#{target} transition을 찾을 수 없음: #{issue_key}" unless found

      @client.post("/issue/#{issue_key}/transitions", {
        transition: { id: found["id"] }
      })
    end
  end
end
