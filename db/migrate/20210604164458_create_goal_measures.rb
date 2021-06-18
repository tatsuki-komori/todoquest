class CreateGoalMeasures < ActiveRecord::Migration[6.1]
  def change
    create_table :measures do |t|
      t.integer :goal_id
      t.string :measure_body
      t.timestamps null: false
    end
  end
end
