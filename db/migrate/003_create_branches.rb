class CreateBranches < ActiveRecord::Migration
  def up
    create_table :branches, id: :uuid do |t|
      t.uuid :repository_id, null: false
      t.string :name, null: false
      t.string :current_commit_id, limit: 40, null: false
      t.timestamps
      t.index :created_at
      t.index :updated_at
    end
    add_foreign_key :branches, :repositories
    add_foreign_key :branches, :commits, column: :current_commit_id, dependent: :delete
    add_index :branches, :name
    add_index :branches, [:repository_id,:name], unique: true

    execute %[ALTER TABLE branches ALTER COLUMN created_at SET DEFAULT current_timestamp ]
    execute %[ALTER TABLE branches ALTER COLUMN updated_at SET DEFAULT current_timestamp ]
    execute %[CREATE TRIGGER update_updated_at_column_of_branches BEFORE UPDATE
                ON branches FOR EACH ROW EXECUTE PROCEDURE 
                update_updated_at_column(); ]

  end

  def down
    drop_table :branches
  end

end
