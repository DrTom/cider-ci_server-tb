require 'active_record/connection_adapters/abstract/schema_definitions'


class CreateCommits < ActiveRecord::Migration

  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end

  def up

    create_table :commits, id: false do |t|
      t.string :id, limit: 40

      t.string :tree_id, limit: 40
      t.index :tree_id

      t.integer :depth

      t.string :author_name
      t.string :author_email
      t.timestamp :author_date
      t.index :author_date

      t.string :committer_name
      t.string :committer_email
      t.timestamp :committer_date
      t.index :committer_date

      t.text :subject
      t.text :body

      t.timestamps
      t.index :created_at
    end

    create_text_index :commits, :body
    create_text_index :commits, :author_name
    create_text_index :commits, :author_email
    create_text_index :commits, :committer_name
    create_text_index :commits, :committer_email
    create_text_index :commits, :subject
    create_text_index :commits, :body

    execute 'ALTER TABLE commits ADD PRIMARY KEY (id);'
    execute %[ALTER TABLE commits ALTER COLUMN created_at SET DEFAULT current_timestamp ]
    execute %[ALTER TABLE commits ALTER COLUMN updated_at SET DEFAULT current_timestamp ]

    execute %[
     CREATE TRIGGER update_updated_at_column_of_commits BEFORE UPDATE
        ON commits FOR EACH ROW EXECUTE PROCEDURE 
        update_updated_at_column(); ]

    create_table :commit_arcs, id: false do |t|
      t.string :parent_id, limit: 40, null: false
      t.string :child_id, limit: 40, null: false
    end
    add_index :commit_arcs, [:parent_id,:child_id], unique: true
    add_index :commit_arcs, [:child_id,:parent_id]
    add_foreign_key :commit_arcs, :commits, column: :parent_id, dependent: :delete
    add_foreign_key :commit_arcs, :commits, column: :child_id, dependent: :delete
  end

  def down
    drop_table :commit_arcs
    execute %[DROP TRIGGER  update_updated_at_column_of_commits ON commits ]
    drop_table :commits
  end
end
