class BranchesCommits < ActiveRecord::Migration

  def up
    create_table :branches_commits , id: false do |t| 
      t.uuid :branch_id
      t.string :commit_id, limit: 40
    end
    execute 'ALTER TABLE branches_commits ADD PRIMARY KEY (commit_id,branch_id);'
    add_foreign_key :branches_commits, :commits, dependent: :delete
    add_foreign_key :branches_commits, :branches, dependent: :delete

    execute %[
      CREATE OR REPLACE FUNCTION with_descendants(varchar(40)) RETURNS table(descendant_id varchar)
      AS $$
      WITH RECURSIVE arcs(parent_id,child_id) AS
        (SELECT NULL::varchar, $1::varchar
          UNION
         SELECT commit_arcs.* FROM commit_arcs, arcs WHERE arcs.child_id = commit_arcs.parent_id
        )
      SELECT child_id FROM arcs
      $$ LANGUAGE SQL ]

    execute %[
      CREATE OR REPLACE FUNCTION is_descendant(node varchar(40), possible_descendant varchar(40) ) RETURNS boolean
      AS $$
        SELECT ( EXISTS (SELECT * FROM with_descendants(node) WHERE descendant_id = possible_descendant)
                  AND $1 <> $2 )
      $$ LANGUAGE SQL ]


    execute %[
      CREATE OR REPLACE FUNCTION with_ancestors(varchar(40)) RETURNS table(ancestor_id varchar)
      AS $$
      WITH RECURSIVE arcs(parent_id,child_id) AS
        (SELECT $1::varchar, NULL::varchar
          UNION
         SELECT commit_arcs.* FROM commit_arcs, arcs WHERE arcs.parent_id = commit_arcs.child_id
        )
      SELECT parent_id FROM arcs
      $$ LANGUAGE SQL ]

    execute %[
      CREATE OR REPLACE FUNCTION is_ancestor(node varchar(40), possible_ancestor varchar(40) ) RETURNS boolean
      AS $$
        SELECT ( EXISTS (SELECT * FROM with_ancestors(node) WHERE ancestor_id = possible_ancestor)
                  AND $1 <> $2 )
      $$ LANGUAGE SQL ]

    execute %[
      CREATE OR REPLACE FUNCTION fast_forward_ancestors_to_be_added_to_branches_commits(branch_id UUID, commit_id varchar(40)) RETURNS TABLE (branch_id UUID , commit_id varchar(40))
      AS $$
        WITH RECURSIVE arcs(parent_id,child_id) AS
          (SELECT $2::varchar, NULL::varchar
            UNION
           SELECT commit_arcs.* FROM commit_arcs, arcs 
            WHERE arcs.parent_id = commit_arcs.child_id
            AND NOT EXISTS (SELECT 1 FROM branches_commits WHERE commit_id = arcs.parent_id AND branch_id = $1)
          )
        SELECT DISTINCT $1, parent_id FROM arcs
        WHERE NOT EXISTS (SELECT * FROM branches_commits WHERE commit_id = parent_id AND branch_id = $1)
      $$ LANGUAGE SQL ]

    execute %[
      CREATE OR REPLACE FUNCTION add_fast_forward_ancestors_to_branches_commits(branch_id UUID, commit_id varchar(40)) RETURNS VOID
      AS $$
      INSERT INTO branches_commits (branch_id,commit_id)
        SELECT * FROM fast_forward_ancestors_to_be_added_to_branches_commits(branch_id,commit_id)
      $$ LANGUAGE SQL ]

    execute %[
      CREATE OR REPLACE FUNCTION update_branches_commits (branch_id UUID, new_commit_id varchar(40), old_commit_id varchar(40)) RETURNS varchar
      AS $$
      BEGIN
        CASE 
        WHEN (branch_id IS NULL) THEN 
          RAISE 'branch_id may not be null';
        WHEN NOT EXISTS (SELECT * FROM branches WHERE id = branch_id) THEN 
          RAISE 'branch_id must refer to an existing branch';
        WHEN new_commit_id IS NULL THEN
          RAISE 'new_commit_id may not be null';
        WHEN NOT EXISTS (SELECT * FROM commits WHERE id = new_commit_id) THEN
          RAISE 'new_commit_id must refer to an existing commit';
        WHEN old_commit_id IS NULL THEN 
          -- entirely new branch (nothing should be in branches_commits)
          -- or request a complete reset by setting old_commit_id to NULL 
          DELETE FROM branches_commits WHERE branches_commits.branch_id = $1;
        WHEN NOT is_ancestor(new_commit_id,old_commit_id) THEN
          -- this is the hard non fast forward case
          -- remove all ancestors of old_commit_id which are not ancestors of new_commit_id
          DELETE FROM branches_commits 
            WHERE branches_commits.branch_id = $1 
            AND branches_commits.commit_id IN ( SELECT * FROM with_ancestors(old_commit_id) 
                                EXCEPT SELECT * from with_ancestors(new_commit_id) );
        ELSE 
          -- this is the fast forward case; see last statement
        END CASE;
        -- whats left is adding as if we are in the fast forward case
        PERFORM add_fast_forward_ancestors_to_branches_commits(branch_id,new_commit_id);
        RETURN 'done';
      END;
      $$ LANGUAGE plpgsql ]

  end

  def down
    execute %[ DROP FUNCTION IF EXISTS update_branches_commits (branch_id UUID, new_commit_id varchar(40), old_commit_id varchar(40)) ]
    execute %[ DROP FUNCTION IF EXISTS add_fast_forward_ancestors_to_branches_commits(branch_id UUID, commit_id varchar(40)) ]
    execute %[ DROP FUNCTION IF EXISTS fast_forward_ancestors_to_be_added_to_branches_commits(branch_id UUID, commit_id varchar(40)) ]
    execute %[ DROP FUNCTION IF EXISTS is_descendant(node varchar(40), possible_descendant varchar(40) ) ]
    execute %[ DROP FUNCTION IF EXISTS with_descendants(varchar(40)) ]
    execute %[ DROP FUNCTION IF EXISTS is_ancestor(node varchar(40), possible_ancestor varchar(40) ) ]
    execute %[ DROP FUNCTION IF EXISTS with_ancestors(varchar(40)) ]

    drop_table :branches_commits
  end

end
