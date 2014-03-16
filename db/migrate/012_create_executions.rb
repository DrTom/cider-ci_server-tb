class CreateExecutions < ActiveRecord::Migration
  def up
    create_table :executions, id: :uuid do |t|

      t.string :state, default: 'pending', null: false
      t.text :substituted_specification_data

      t.string :tree_id, null: false, limit: 40
      t.index :tree_id

      t.uuid :specification_id, null: false
      t.index :specification_id

      t.string :definition_name, null: false

      t.integer :priority, default: 5

      t.text :error, null: false, default: ""

      t.timestamps
      t.index :created_at
    end

    add_index :executions, [:tree_id,:specification_id], unique: true
    add_foreign_key :executions, :specifications
  end

  def down
    drop_table :executions
  end

end
