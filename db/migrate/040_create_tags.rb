class CreateTags < ActiveRecord::Migration
  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end

  def up
    create_table :tags, id: :uuid do |t|
      t.string :tag
      t.timestamps
    end
    add_index :tags, :tag
    create_text_index :tags, :tag

    create_table :executions_tags, id: false do |t|
      t.uuid :execution_id
      t.uuid :tag_id
    end
    add_index :executions_tags,[:execution_id,:tag_id], unique: true
    add_index :executions_tags,[:tag_id,:execution_id]

    add_foreign_key :executions_tags, :executions, dependent: :delete
    add_foreign_key :executions_tags, :tags, dependent: :delete

    create_table :branch_update_triggers_tags, id: false do |t|
      t.uuid :branch_update_trigger_id
      t.uuid :tag_id
    end
    add_index :branch_update_triggers_tags, [:branch_update_trigger_id,:tag_id], unique: true, name: "trigger_tag_idx"
    add_index :branch_update_triggers_tags, [:tag_id,:branch_update_trigger_id], name: "tag_trigger_idx"
    add_foreign_key :branch_update_triggers_tags, :branch_update_triggers, dependent: :delete
    add_foreign_key :branch_update_triggers_tags, :tags, dependent: :delete

  end

  def down
    drop_table :branch_update_triggers_tags
    drop_table :executions_tags
    drop_table :tags
  end

end
