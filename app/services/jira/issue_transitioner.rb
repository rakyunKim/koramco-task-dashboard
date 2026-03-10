module Jira
  class IssueTransitioner
    def initialize(client = Client.new)
      @client = client
    end

    def transition_to_done(issue_key)
      transitions = @client.get("/issue/#{issue_key}/transitions")
      done_transition = transitions["transitions"].find do |t|
        t.dig("to", "statusCategory", "key") == "done"
      end

      raise Jira::Error, "Done transition을 찾을 수 없음: #{issue_key}" unless done_transition

      @client.post("/issue/#{issue_key}/transitions", {
        transition: { id: done_transition["id"] }
      })
    end
  end
end
