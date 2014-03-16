
-- ######################################


CREATE OR REPLACE FUNCTION array_sort (ANYARRAY)
RETURNS ANYARRAY LANGUAGE SQL
AS $$
SELECT ARRAY(SELECT unnest($1) ORDER BY 1)
$$;

DROP FUNCTION  commit_branches(varchar);

CREATE OR REPLACE FUNCTION commit_branches(varchar(40)) RETURNS  UUID[]
AS $$
WITH RECURSIVE arcs(parent_id,child_id) AS
  (SELECT NULL::varchar, $1::varchar
   UNION SELECT commit_arcs.*
   FROM arcs,
        commit_arcs
   WHERE arcs.child_id = commit_arcs.parent_id)
SELECT array_sort(array_agg(branches.id))
FROM arcs , branches
WHERE current_commit_id = arcs.child_id 
$$ LANGUAGE SQL
;

SELECT * from commit_branches('698c0ca11c2d991d357810a48db5be9980fb8c0a'::varchar);

SELECT * from array_to_string(commit_branches('799c9d036cc0691e7c4503ef531c4fb340fd5d14'::varchar),', ');




SELECT DISTINCT "executions".*
FROM "executions"
INNER JOIN "trees" ON "trees"."id" = "executions"."tree_id"
INNER JOIN "commits" ON "commits"."tree_id" = "trees"."id"
INNER JOIN "branches_commits" ON "branches_commits"."commit_id" = "commits"."id"
INNER JOIN "branches" ON "branches"."id" = "branches_commits"."branch_id"
INNER JOIN "repositories" ON "repositories"."id" = "branches"."repository_id"
WHERE "repositories"."name" IN ('Domina CI Executor')
ORDER BY "executions"."created_at" DESC LIMIT 10
OFFSET 0;


SELECT DISTINCT "executions".*
FROM "executions"
INNER JOIN "trees" ON "trees"."id" = "executions"."tree_id"
INNER JOIN "commits" ON "commits"."tree_id" = "trees"."id"
INNER JOIN "branches_commits" ON "branches_commits"."commit_id" = "commits"."id"
INNER JOIN "branches" ON "branches"."id" = "branches_commits"."branch_id"
INNER JOIN "repositories" ON "repositories"."id" = "branches"."repository_id"
WHERE (repositories.name = 'Domina CI Server')
ORDER BY "executions"."created_at" DESC LIMIT 10
OFFSET 0
;

SELECT * from repositories
WHERE (repositories.name = 'Domina CI Server')
;


SELECT execution_id,
       stats_signature,
       commits_signature,
       branches_signature
FROM "execution_cache_signatures"
WHERE (execution_id IN (NULL));

SELECT "executions".*
FROM "executions"
INNER JOIN "executions_tags" ON "executions_tags"."execution_id" = "executions"."id"
INNER JOIN "tags" ON "tags"."id" = "executions_tags"."tag_id"
WHERE TRUE 
-- AND (tags.tag = 'rails4')
AND (tags.tag = 'ts')
ORDER BY "executions"."created_at" DESC LIMIT 10
OFFSET 0 ;


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
;




SELECT executions.id, 
(select count(*) from tasks where tasks.execution_id = executions.id) as total,
(select count(*) from tasks where tasks.execution_id = executions.id and state = 'pending') as pending,
(select count(*) from tasks where tasks.execution_id = executions.id and state = 'executing') as executing,
(select count(*) from tasks where tasks.execution_id = executions.id and state = 'failed') as failed,
(select count(*) from tasks where tasks.execution_id = executions.id and state = 'success') as success
FROM executions
--WHERE executions.id = '4948b8ed-3021-49d2-a685-9d2815961980'
;

SELECT DISTINCT executions.id, trials.state
, count(trials.state) OVER (PARTITION BY trials.state)
FROM executions
LEFT OUTER JOIN tasks ON tasks.execution_id = executions.id
LEFT OUTER JOIN trials ON trials.task_id = tasks.id
WHERE executions.id = '4948b8ed-3021-49d2-a685-9d2815961980'
;



SELECT _stats.id, _pending.count AS pending, _finished.count AS finished
FROM _stats
RIGHT OUTER JOIN _stats AS _pending ON _stats.id = _pending.id
RIGHT OUTER JOIN _stats AS _finished ON _stats.id = _finished.id
WHERE _stats.id = '4948b8ed-3021-49d2-a685-9d2815961980'
AND _pending.state = 'pending';
AND _finished.state = 'finished' limit 10;


SELECT * from _stats
WHERE _stats.id = '4948b8ed-3021-49d2-a685-9d2815961980'
;


SELECT *
FROM _stats
WHERE true
AND _stats.id = '84140ed4-d9d8-4c21-9504-e5accfe52091' ;


SELECT *
FROM _stats
LEFT OUTER JOIN _stats as _pending ON _stats.id = _pending.id
WHERE true
AND _pending.state = 'pending'
AND _stats.id = '84140ed4-d9d8-4c21-9504-e5accfe52091' ;


CREATE OR REPLACE VIEW  _stats AS 
SELECT executions.id, trials.state, count(trials.*)
FROM executions
LEFT OUTER JOIN tasks ON tasks.execution_id = executions.id
LEFT OUTER JOIN trials ON trials.task_id = tasks.id
GROUP BY executions.id, trials.state;

SELECT executions.id as execution_id,
       md5(string_agg(DISTINCT branches.updated_at::text,', 'ORDER BY branches.updated_at::text)) AS branches_signature,
       md5(string_agg(DISTINCT commits.updated_at::text,', 'ORDER BY commits.updated_at::text)) AS commits_signature,
       md5(string_agg(DISTINCT repositories.updated_at::text,', 'ORDER BY repositories.updated_at::text)) AS repositories_signature,
       md5(string_agg(DISTINCT tasks.updated_at::text,', 'ORDER BY tasks.updated_at::text)) AS tasks_signature,
       md5(string_agg(DISTINCT trials.updated_at::text,', 'ORDER BY trials.updated_at::text)) AS trials_signature
FROM executions
LEFT OUTER JOIN commits ON executions.tree_id = commits.tree_id
LEFT OUTER JOIN branches_commits ON branches_commits.commit_id = commits.id
LEFT OUTER JOIN branches ON branches_commits.branch_id= branches.id
LEFT OUTER JOIN repositories ON branches.repository_id= repositories.id
LEFT OUTER JOIN tasks ON tasks.execution_id = executions.id
LEFT OUTER JOIN trials ON trials.task_id = tasks.id
GROUP BY executions.id;

SELECT executions.id,
FROM executions
GROUP BY executions.id;
 ;




SELECT "trials".*
FROM "trials"
INNER JOIN "tasks" ON "tasks"."id" = "trials"."task_id"
WHERE "trials"."state" = 'pending'
  AND (trials.updated_at < (now() - interval '60 Minutes'))
ORDER BY "trials"."priority" DESC,
         tasks.created_at ASC,
         "trials"."created_at" DESC,
         "trials"."id" ASC
        ;


SELECT "trials".*
FROM "trials"
INNER JOIN "tasks" ON "tasks"."id" = "trials"."task_id"
WHERE "trials"."state" = 'pending'
  AND (trials.created_at < (now() - interval '60 Minutes'))
;

-- uuid pkey for execution 
ALTER TABLE executions ADD id uuid;
UPDATE executions SET id = uuid_generate_v4();
ALTER TABLE tasks ADD execution_id uuid;
UPDATE tasks 
  SET execution_id = executions.id
  FROM executions
  WHERE tasks.tree_id = executions.tree_id
  AND tasks.specification_id = executions.specification_id;
ALTER TABLE tasks DROP tree_id;
ALTER TABLE tasks DROP specification_id;


SELECT DISTINCT "users".*,
                COALESCE(ts_rank(to_tsvector('english', "users"."login"::text), plainto_tsquery('english', 'algocon'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "users"."last_name"::text), plainto_tsquery('english', 'algocon'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "users"."first_name"::text), plainto_tsquery('english', 'algocon'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "email_addresses"."email_address"::text), plainto_tsquery('english', 'algocon'::text)), 0) AS "rank55070702552416812"
FROM "users"
INNER JOIN "email_addresses" ON "email_addresses"."user_id" = "users"."id"
WHERE (to_tsvector('english', "users"."login"::text) @@ plainto_tsquery('english', 'algocon'::text)
       OR to_tsvector('english', "users"."last_name"::text) @@ plainto_tsquery('english', 'algocon'::text)
       OR to_tsvector('english', "users"."first_name"::text) @@ plainto_tsquery('english', 'algocon'::text)
       OR to_tsvector('english', "email_addresses"."email_address"::text) @@ plainto_tsquery('english', 'algocon'::text))
ORDER BY "users"."last_name" ASC,
         "users"."first_name" ASC LIMIT 25

OFFSET 0
SELECT "commits".*,
       COALESCE(ts_rank(to_tsvector('english', "commits"."id"::text), plainto_tsquery('english', 'Permissions\ Franco'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "commits"."tree_id"::text), plainto_tsquery('english', 'Permissions\ Franco'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "commits"."author_name"::text), plainto_tsquery('english', 'Permissions\ Franco'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "commits"."author_email"::text), plainto_tsquery('english', 'Permissions\ Franco'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "commits"."committer_name"::text), plainto_tsquery('english', 'Permissions\ Franco'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "commits"."committer_email"::text), plainto_tsquery('english', 'Permissions\ Franco'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "commits"."subject"::text), plainto_tsquery('english', 'Permissions\ Franco'::text)), 0) + COALESCE(ts_rank(to_tsvector('english', "commits"."body"::text), plainto_tsquery('english', 'Permissions\ Franco'::text)), 0) AS "rank47121221514201163"
FROM "commits"
INNER JOIN "branches_commits" ON "branches_commits"."commit_id" = "commits"."id"
INNER JOIN "branches" ON "branches"."id" = "branches_commits"."branch_id"
INNER JOIN "repositories" ON "repositories"."id" = "branches"."repository_id"
WHERE (branches.name = 'next')
  AND (repositories.name = 'Madek')
  AND (to_tsvector('english', "commits"."id"::text) @@ plainto_tsquery('english', 'Permissions\ Franco'::text)
       OR to_tsvector('english', "commits"."tree_id"::text) @@ plainto_tsquery('english', 'Permissions\ Franco'::text)
       OR to_tsvector('english', "commits"."author_name"::text) @@ plainto_tsquery('english', 'Permissions\ Franco'::text)
       OR to_tsvector('english', "commits"."author_email"::text) @@ plainto_tsquery('english', 'Permissions\ Franco'::text)
       OR to_tsvector('english', "commits"."committer_name"::text) @@ plainto_tsquery('english', 'Permissions\ Franco'::text)
       OR to_tsvector('english', "commits"."committer_email"::text) @@ plainto_tsquery('english', 'Permissions\ Franco'::text)
       OR to_tsvector('english', "commits"."subject"::text) @@ plainto_tsquery('english', 'Permissions\ Franco'::text)
       OR to_tsvector('english', "commits"."body"::text) @@ plainto_tsquery('english', 'Permissions\ Franco'::text))
ORDER BY "commits"."committer_date" DESC,
         "rank47121221514201163" DESC,
         "commits"."committer_date" DESC,
         "commits"."created_at" DESC,
         "commits"."id" ASC LIMIT 25
OFFSET 00;

EXPLAIN ANALYZE SELECT DISTINCT commits.*
FROM commits,
     branches AS h_branches
INNER JOIN repositories AS h_repositories ON h_repositories.id = h_branches.repository_id
WHERE ( (h_branches.current_commit_id IN
           (SELECT d_commits.id
            FROM commits AS d_commits
            INNER JOIN "branches" AS d_branches ON "d_branches"."current_commit_id" = "d_commits"."id"
            WHERE (id IN (WITH RECURSIVE descendants AS
                            (SELECT *
                             FROM commits AS s_commits
                             WHERE ID = commits.id
                             UNION SELECT r_commits.*
                             FROM descendants,
                                  commit_arcs,
                                  commits AS r_commits
                             WHERE TRUE
                               AND descendants.id = commit_arcs.parent_id
                               AND commit_arcs.child_id = r_commits.id)
                          SELECT id
                          FROM descendants)) )))
ORDER BY "commits"."committer_date" DESC,
         "commits"."created_at" DESC,
         "commits"."id" ASC LIMIT 25
OFFSET 0;

-- EXAMPLE QUERY: branch joined with heads
SELECT  commits.id, h_branches.name
FROM commits, branches as h_branches 
WHERE (h_branches.current_commit_id IN
         (SELECT d_commits.id
          FROM commits AS d_commits
          INNER JOIN "branches" AS d_branches ON "d_branches"."current_commit_id" = "d_commits"."id"
          WHERE (id IN (WITH RECURSIVE descendants AS
                          (SELECT *
                           FROM commits as s_commits
                           WHERE ID = commits.id 
                           UNION SELECT r_commits.*
                           FROM descendants,
                                commit_arcs,
                                commits AS r_commits
                           WHERE TRUE
                             AND descendants.id = commit_arcs.parent_id
                             AND commit_arcs.child_id = r_commits.id)
                        SELECT id
                        FROM descendants))
          ))
ORDER BY commits.id 
;



SELECT commits.* FROM commits;


SELECT "commits".*
FROM "commits"
INNER JOIN "branches" ON "branches"."current_commit_id" = "commits"."id"
WHERE (id IN ( WITH RECURSIVE descendants AS
                ( SELECT *
                 FROM commits
                 WHERE ID IN
                     (SELECT id
                      FROM "commits"
                      WHERE (id LIKE '3c1bdc8%')
                      ORDER BY "commits"."created_at" DESC, "commits"."id" ASC)
                 UNION SELECT commits.*
                 FROM descendants,
                      commit_arcs,
                      commits
                 WHERE TRUE
                   AND descendants.id = commit_arcs.parent_id
                   AND commit_arcs.child_id = commits.id )
              SELECT id
              FROM descendants))
ORDER BY "commits"."created_at" DESC,
         "commits"."id" ASC
        ;



SELECT date_part('epoch', SUM(finished_at - started_at)) AS total_duration
FROM "trials"
INNER JOIN "tasks" ON "tasks"."id" = "trials"."task_id"
INNER JOIN "executions" ON "executions"."specification_id" = "tasks"."specification_id"
AND "executions"."tree_id" = "tasks"."tree_id"
WHERE (executions.tree_id = 'a0c367830344212ef0878d2dfb2b419fd4248a6c')
  AND (executions.specification_id = 'a019b15a-2609-5a56-af25-e80bdbf9c2c0')
  AND ("trials"."started_at" IS NOT NULL)
  AND ("trials"."finished_at" IS NOT NULL)
GROUP BY executions.tree_id
;

SELECT "executors_with_load".*
FROM executors_with_load,
     tasks
WHERE "executors_with_load"."enabled" = 't'
  AND (tasks.id = '2c3a46fd-ba30-4916-ba6f-5f1526256729')
  AND (tasks.environments <@ executors_with_load.environments)
  AND (last_ping_at > (now() - interval '3 Minutes'))
  AND (executors_with_load.relative_load < 1)
ORDER BY "executors_with_load"."relative_load" ASC,
         "executors_with_load".name ASC ;

SELECT * FROM COMMITS WHERE ID = '643cebb11bc062419bd0d9ab8eeb0a03d0392d26'

WITH RECURSIVE ancestors AS
(
  SELECT * FROM commits WHERE ID = '643cebb11bc062419bd0d9ab8eeb0a03d0392d26'
  UNION 
  SELECT commits.* 
    FROM ancestors, commit_arcs, commits
    WHERE TRUE
    AND ancestors.id = commit_arcs.child_id
    AND commit_arcs.parent_id = commits.id
)
SELECT * FROM ancestors

