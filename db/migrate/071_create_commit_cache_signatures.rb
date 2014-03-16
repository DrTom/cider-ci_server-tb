class CreateCommitCacheSignatures < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW commit_cache_signatures AS
        SELECT commits.id AS commit_id,
               md5(string_agg(DISTINCT branches.updated_at::text,', 'ORDER BY branches.updated_at::text)) AS branches_signature,
               md5(string_agg(DISTINCT repositories.updated_at::text,', 'ORDER BY repositories.updated_at::text)) AS repositories_signature,
               md5(string_agg(DISTINCT executions.updated_at::text,', 'ORDER BY executions.updated_at::text)) AS executions_signature
        FROM commits
        LEFT OUTER JOIN branches_commits ON branches_commits.commit_id = commits.id
        LEFT OUTER JOIN branches ON branches_commits.branch_id= branches.id
        LEFT OUTER JOIN executions ON executions.tree_id = commits.tree_id
        LEFT OUTER JOIN repositories ON branches.repository_id= repositories.id
        GROUP BY commits.id
    SQL
  end

  def down
    execute %[ DROP VIEW commit_cache_signatures ]
  end
end
