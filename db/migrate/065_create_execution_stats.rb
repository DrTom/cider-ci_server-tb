class CreateExecutionStats < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW execution_stats AS
        SELECT executions.id as execution_id, 
        (select count(*) from tasks where tasks.execution_id = executions.id) as total,
        (select count(*) from tasks where tasks.execution_id = executions.id and state = 'pending') as pending,
        (select count(*) from tasks where tasks.execution_id = executions.id and state = 'executing') as executing,
        (select count(*) from tasks where tasks.execution_id = executions.id and state = 'failed') as failed,
        (select count(*) from tasks where tasks.execution_id = executions.id and state = 'success') as success
        FROM executions
    SQL
  end
  def down
    execute %[ DROP VIEW execution_stats ]
  end
end
