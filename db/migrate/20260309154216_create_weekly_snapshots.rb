class CreateWeeklySnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :weekly_snapshots do |t|
      t.references :wig, null: false, foreign_key: true
      t.references :lead_measure, foreign_key: true
      t.date :week_start_date, null: false
      t.decimal :target_value, precision: 10, scale: 2
      t.decimal :achieved_value, precision: 10, scale: 2
      t.string :snapshot_type, null: false
      t.timestamps
    end
    add_index :weekly_snapshots, [:wig_id, :week_start_date]
  end
end
