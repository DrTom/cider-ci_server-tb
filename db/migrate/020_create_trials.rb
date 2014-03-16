class CreateTrials < ActiveRecord::Migration
  def up
    create_table :trials, id: :uuid do |t|

      t.uuid :task_id, null: false
      t.index :task_id
      t.uuid :executor_id

      t.text :error
      t.string :state, null: false, default: 'pending'

      t.json :scripts 

      t.timestamp :started_at
      t.timestamp :finished_at

      t.timestamps
      t.index :created_at

    end
    add_foreign_key :trials, :tasks, dependent: :delete

  end

  def down
    drop_table :trials
  end
end
