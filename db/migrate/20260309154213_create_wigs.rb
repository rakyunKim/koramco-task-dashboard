class CreateWigs < ActiveRecord::Migration[8.1]
  def change
    create_table :wigs do |t|
      t.string :title, null: false
      t.text :description
      t.decimal :target_value, precision: 10, scale: 2, null: false
      t.decimal :current_value, precision: 10, scale: 2, default: 0
      t.string :unit, default: ""
      t.date :deadline
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
