class AddJiraFieldsToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :jira_issue_key, :string
    add_column :tasks, :jira_issue_id,  :string
    add_column :tasks, :jira_synced_at, :datetime

    add_index :tasks, :jira_issue_key, unique: true
    add_index :tasks, :jira_issue_id,  unique: true
  end
end
