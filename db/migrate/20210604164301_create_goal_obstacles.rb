class CreateGoalObstacles < ActiveRecord::Migration[6.1]
  def change
    create_table :obstacles do |t|
      t.integer :goal_id
      t.string :obstacle_body
      t.timestamps null: false
    end
  end
end
