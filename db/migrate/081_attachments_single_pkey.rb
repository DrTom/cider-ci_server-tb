class AttachmentsSinglePkey < ActiveRecord::Migration
  def change

    add_column :attachments, :id, :uuid, null: false, default: 'uuid_generate_v4()'

    reversible do |dir|

      dir.up do
        execute 'ALTER TABLE attachments DROP CONSTRAINT attachments_pkey'
        execute 'ALTER TABLE attachments ADD PRIMARY KEY (id)'
      end

      dir.down do
        execute 'ALTER TABLE attachments DROP CONSTRAINT attachments_pkey'
        execute 'ALTER TABLE attachments ADD PRIMARY KEY (trial_id,path)'
      end

    end

    add_index :attachments, [:trial_id, :path], unique:  true

  end
end
