class SetArraysDefaultAndNeverNull < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        execute "ALTER TABLE executors ALTER traits set default '{}'"
        execute "UPDATE executors SET traits = '{}' WHERE traits is NULL"
        execute "ALTER TABLE executors ALTER traits set not null"
      end
    end
  end
end
