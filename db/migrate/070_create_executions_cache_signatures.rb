class CreateExecutionsCacheSignatures < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW execution_cache_signatures AS
        SELECT executions.id as execution_id,
               string_agg(DISTINCT execution_stats.total::text, ', ')
               || '-' || string_agg(DISTINCT execution_stats.pending::text, ', ')
               || '-' || string_agg(DISTINCT execution_stats.executing::text, ', ')
               || '-' || string_agg(DISTINCT execution_stats.failed::text, ', ')
               || '-' || string_agg(DISTINCT execution_stats.success::text, ', ') AS stats_signature,
               md5(string_agg(DISTINCT branches.updated_at::text,', 'ORDER BY branches.updated_at::text)) AS branches_signature,
               md5(string_agg(DISTINCT commits.updated_at::text,', 'ORDER BY commits.updated_at::text)) AS commits_signature,
               md5(string_agg(DISTINCT repositories.updated_at::text,', 'ORDER BY repositories.updated_at::text)) AS repositories_signature,
               md5(string_agg(DISTINCT tags.updated_at::text,', 'ORDER BY tags.updated_at::text)) AS tags_signature,
               md5(string_agg(DISTINCT tasks.updated_at::text,', 'ORDER BY tasks.updated_at::text)) AS tasks_signature,
               md5(string_agg(DISTINCT trials.updated_at::text,', 'ORDER BY trials.updated_at::text)) AS trials_signature
        FROM executions
        INNER JOIN execution_stats ON execution_stats.execution_id = executions.id
        LEFT OUTER JOIN commits ON executions.tree_id = commits.tree_id
        LEFT OUTER JOIN branches_commits ON branches_commits.commit_id = commits.id
        LEFT OUTER JOIN branches ON branches_commits.branch_id= branches.id
        LEFT OUTER JOIN repositories ON branches.repository_id= repositories.id
        LEFT OUTER JOIN tasks ON tasks.execution_id = executions.id
        LEFT OUTER JOIN trials ON trials.task_id = tasks.id
        LEFT OUTER JOIN executions_tags ON executions_tags.execution_id = executions.id
        LEFT OUTER JOIN tags ON executions_tags.tag_id = tags.id
        GROUP BY executions.id;
    SQL
  end

  def down
    execute %[ DROP VIEW  execution_cache_signatures ]
  end
end
