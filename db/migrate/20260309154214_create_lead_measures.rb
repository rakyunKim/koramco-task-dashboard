class CreateLeadMeasures < ActiveRecord::Migration[8.1]
  def change
    create_table :lead_measures do |t|
      t.references :wig, null: false, foreign_key: true
      t.string :title, null: false
      t.decimal :weekly_target, precision: 10, scale: 2, null: false
      t.decimal :current_value, precision: 10, scale: 2, default: 0
      t.string :unit, default: ""
      t.date :week_start_date, null: false
      t.timestamps
    end
    add_index :lead_measures, [:wig_id, :week_start_date]
  end
end
