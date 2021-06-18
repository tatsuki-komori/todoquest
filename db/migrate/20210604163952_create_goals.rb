class CreateGoals < ActiveRecord::Migration[6.1]
  def change
    create_table :goals do |t|
      t.integer :user_id
      t.string :goal_body
      t.string :title_name
      t.boolean :achieve_goal
      t.timestamps null: false
    end
  end
end
