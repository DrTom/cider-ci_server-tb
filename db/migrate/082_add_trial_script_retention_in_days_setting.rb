class AddTrialScriptRetentionInDaysSetting < ActiveRecord::Migration
  def change
    add_column :timeout_settings, :trial_scripts_retention_time_days, :integer, null: false, default: 10
    reversible do |direction|
      direction.up do
        execute "UPDATE trials SET scripts = '[]' WHERE scripts IS NULL"
        change_column :trials, :scripts, :json, default: '[]', null: false
        execute "CREATE INDEX trials_scripts_count_idx ON trials(json_array_length(scripts))"
      end
      direction.down do
        execute 'DROP INDEX trials_scripts_count_idx'
      end
    end
  end
end
