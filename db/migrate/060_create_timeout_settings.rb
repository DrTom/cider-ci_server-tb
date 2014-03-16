class CreateTimeoutSettings < ActiveRecord::Migration
  def up
    create_table :timeout_settings, id: false  do |t|
      t.integer :id

      t.integer :attachment_retention_time_hours, default: 8, null: false

      t.integer :trial_dispatch_timeout_minutes, default: 60, null: false
      t.integer :trial_end_state_timeout_minutes, default: 180, null: false
      t.integer :trial_execution_timeout_minutes, default: 5, null: false

      t.timestamps
    end

    execute "ALTER TABLE timeout_settings ADD PRIMARY KEY (id)"
    execute "ALTER TABLE timeout_settings ADD CONSTRAINT one_and_only_one CHECK (id = 0)"

    execute "ALTER TABLE timeout_settings ADD CONSTRAINT attachment_retention_time_hours_positive CHECK (attachment_retention_time_hours > 0)"

    execute "ALTER TABLE timeout_settings ADD CONSTRAINT trial_dispatch_timeout_minutes_positive CHECK (trial_dispatch_timeout_minutes > 0)"
    execute "ALTER TABLE timeout_settings ADD CONSTRAINT trial_end_state_timeout_minutes_positive CHECK (trial_end_state_timeout_minutes > 0)"
    execute "ALTER TABLE timeout_settings ADD CONSTRAINT trial_execution_timeout_minutes_positive CHECK (trial_execution_timeout_minutes > 0)"
  end

  def down
    drop_table :timeout_settings
  end

end
