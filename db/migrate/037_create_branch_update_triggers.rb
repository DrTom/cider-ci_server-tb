class CreateBranchUpdateTriggers < ActiveRecord::Migration
  def up
    create_table :branch_update_triggers, id: :uuid do |t|
      t.uuid :definition_id, null: false
      t.uuid :branch_id, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    add_index :branch_update_triggers, [:branch_id,:definition_id], unique: true
    add_foreign_key :branch_update_triggers, :definitions, dependent: :delete
    add_foreign_key :branch_update_triggers, :branches, dependent: :delete
  end
  def down
    drop_table :branch_update_triggers
  end
end
