class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :color
      t.timestamps null: false
    end
    
    create_table :task_projects do |t|
      t.integer :task_id
      t.integer :project_id
      t.timestamps null: false
    end
  end
end
