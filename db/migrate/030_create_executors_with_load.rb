class CreateExecutorsWithLoad < ActiveRecord::Migration

  def up
    execute <<-SQL

      CREATE OR REPLACE VIEW executors_with_load AS
        SELECT executors.*, 
            count(trials.executor_id) AS current_load,
            count(trials.executor_id)::float/executors.max_load::float AS relative_load
          FROM executors
          LEFT OUTER JOIN trials ON trials.executor_id = executors.id
            AND trials.state IN ('dispatching', 'executing')
          GROUP BY executors.id

    SQL
  end

  def down
    execute "DROP VIEW executors_with_load"
  end

end
