class CreateAbilities < ActiveRecord::Migration[6.1]
  def change
    create_table :abilities do |t|
      t.string :user_id
      t.string :name
      t.string :color
      t.integer :point, default: 0
      t.timestamps null: false
    end
    
    create_table :task_abilities do |t|
      t.integer :task_id, index: true, foreign_key: true
      t.integer :ability_id, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
