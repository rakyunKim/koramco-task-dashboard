class CreateJiraSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :jira_settings do |t|
      t.string  :site_url,       null: false
      t.string  :email,          null: false
      t.text    :api_token,      null: false
      t.string  :webhook_secret
      t.boolean :active,         default: true

      t.timestamps
    end
  end
end
