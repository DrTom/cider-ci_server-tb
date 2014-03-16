class CreateAttachments < ActiveRecord::Migration
  def up
    create_table :attachments, id: false do |t|
      t.uuid :trial_id, null: false
      t.text :path, null: false

      t.integer :content_length
      t.string :content_type, null: false, default: "application/octet-stream"
      t.text :content 

      t.timestamps
    end
    add_foreign_key :attachments, :trials, dependent: :delete
    execute "ALTER TABLE attachments ADD PRIMARY KEY (trial_id,path);"
  end

  def down
    drop_table :attachments
  end

end
