class Tasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.integer :user_id
      t.string :body
      t.date :deadline_date, default: nil
      t.boolean :achieve_task, default: false
      t.date :achieve_date, default: nil
    end
  end
end
