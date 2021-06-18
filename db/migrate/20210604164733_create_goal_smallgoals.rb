class CreateGoalSmallgoals < ActiveRecord::Migration[6.1]
  def change
    create_table :smallgoals do |t|
      t.integer :goal_id
      t.string :smallgoal_body
      t.boolean :achieve_smallgoal
      t.timestamps null: false
    end
  end
end
