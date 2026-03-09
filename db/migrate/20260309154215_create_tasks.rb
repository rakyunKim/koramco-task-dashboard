class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :lead_measure, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.string :title, null: false
      t.boolean :completed, default: false
      t.decimal :contribution_value, precision: 10, scale: 2, default: 1
      t.date :week_start_date, null: false
      t.datetime :completed_at
      t.timestamps
    end
    add_index :tasks, [:lead_measure_id, :week_start_date]
    add_index :tasks, [:member_id, :week_start_date]
  end
end
