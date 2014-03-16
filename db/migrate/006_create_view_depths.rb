class CreateViewDepths < ActiveRecord::Migration
  def down
    execute "DROP VIEW depths"
  end

  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW depths
      AS SELECT id as commit_id,depth FROM 
      (
      WITH RECURSIVE ancestors(id,depth) AS
        (
          
         -- the roots 
         SELECT id,
                0 AS depth
         FROM commits
         WHERE NOT EXISTS
             (SELECT 1
              FROM commit_arcs
              WHERE commits.id = commit_arcs.child_id)
           AND commits.depth IS NULL 
        
          UNION 

          -- the parents with depth of unset children
          SELECT parents.id, parents.depth FROM commits as parents
            WHERE parents.depth is not NULL
            AND EXISTS ( select 1 FROM commits as children, commit_arcs 
                                           WHERE children.depth is null
                                           AND commit_arcs.child_id = children.id
                                           AND commit_arcs.parent_id = parents.id)
          UNION 

          -- the recursion
          SELECT commits.id, ancestors.depth + 1 
            FROM commits, ancestors, commit_arcs
            WHERE commits.id = commit_arcs.child_id
            AND ancestors.id = commit_arcs.parent_id
            and commits.depth is null
        )
      SELECT ancestors.id, max(ancestors.depth) as depth
      FROM ancestors
      GROUP BY ancestors.id
      ORDER BY depth ) as cd;
    SQL
  end
end
