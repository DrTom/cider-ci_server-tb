class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks, id: :uuid do |t|

      t.uuid :execution_id, null: false
      t.index :execution_id

      t.string :state, default: 'pending', null: false
      t.integer :priority, null: false, default: 5

      t.json :data
      t.string :traits, array: true, null: false, default: '{}'
      t.index :traits 
      t.string :name

      t.text :error, null: false, default: ""

      t.timestamps
      t.index :created_at
    end
    add_foreign_key :tasks, :executions, dependent: :delete
  end


  def down 
    drop_table :tasks
  end

end
