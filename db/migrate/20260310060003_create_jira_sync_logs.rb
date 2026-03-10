class CreateJiraSyncLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :jira_sync_logs do |t|
      t.string     :direction,      null: false
      t.string     :action,         null: false
      t.string     :jira_issue_key
      t.references :task,           foreign_key: true
      t.string     :status,         null: false
      t.text       :error_message

      t.timestamps
    end

    add_index :jira_sync_logs, :status
  end
end
