#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Commit < ActiveRecord::Base
  self.primary_key = 'id'

  has_and_belongs_to_many :branches
  has_and_belongs_to_many :children, class_name: 'Commit', join_table: 'commit_arcs', association_foreign_key: 'child_id', foreign_key: 'parent_id'
  has_and_belongs_to_many :parents, class_name: 'Commit', join_table: 'commit_arcs', foreign_key: 'child_id', association_foreign_key: 'parent_id'
  has_one :commit_cache_signature
  has_many :head_of_branches, class_name: 'Branch', foreign_key: 'current_commit_id'
  has_many :executions, primary_key: 'tree_id', foreign_key: 'tree_id'  #through: :tree 


  default_scope{order(committer_date: :desc,created_at: :desc,id: :asc)}

  def to_s
    id[0..5]
  end

  has_many :repositories, through: :branches

  #def repositories
  #  Repository.joins(branches: :commits).where("commits.id = ?",id).select("DISTINCT repositories.*")
  #end

  def with_ancestors 
    # we should be avoid the subquery "id IN" if we 
    # patch AR to include a WITH statement
    # REMARK: there seems to be with_recursive support in arel; how to use it? 
    Commit.where(" commits.id IN (
      WITH RECURSIVE ancestors AS
      (
        SELECT * FROM commits WHERE ID = ?
        UNION 
        SELECT commits.* 
          FROM ancestors, commit_arcs, commits
          WHERE TRUE
          AND ancestors.id = commit_arcs.child_id
          AND commit_arcs.parent_id = commits.id
      )
      SELECT id FROM ancestors)", id).reorder(committer_date: :desc)
  end

  def with_descendants
    Commit.where(" commits.id IN (
      WITH RECURSIVE descendants AS
      (
        SELECT * FROM commits WHERE ID = ?
        UNION 
        SELECT commits.* 
          FROM descendants, commit_arcs, commits
          WHERE TRUE
          AND descendants.id = commit_arcs.parent_id
          AND commit_arcs.child_id = commits.id
      )
      SELECT id FROM descendants)", id).reorder(committer_date: :desc)
  end

  class << self

    # conceptually recursive, technically not!
    def import_with_parents commit_id, repository_id

      repository = Repository.find repository_id

      # entry in to_be_imported_commit_and_parets_line is an array like [commit_id parent1_commit_id parent2_commit_id ...]
      @to_be_imported_commit_and_parets_line = [] 
      # entry in discovered_unimported_commits is a commit_id
      @discovered_unimported_commits = []
      # 
      @handeled_commits = Set.new

      unless Commit.find_by_id commit_id
        @discovered_unimported_commits << commit_id
        @handeled_commits << commit_id
        import commit_id, repository
      end

      begin 
        id = @discovered_unimported_commits.shift 
        git_parents_cmd = "cd #{repository.dir}; git rev-list -n 1 --parents #{id}"
        to_be_imported_commit = System.execute_cmd!(git_parents_cmd).split(/\s+/)
        @to_be_imported_commit_and_parets_line << to_be_imported_commit
        to_be_imported_commit.drop(1).each do |c_id| 
          unless Commit.find_by_id(c_id) or @handeled_commits.include?(c_id)
            @discovered_unimported_commits << c_id 
            @handeled_commits << c_id
            import c_id,repository
          end
        end
      end while not @discovered_unimported_commits.empty?

      while (commit_line = @to_be_imported_commit_and_parets_line.pop)
        next_commit_id = commit_line.shift
        commit = Commit.find next_commit_id 
        commit.parents << commit_line.map{|id| Commit.find id}
      end

      Commit.find(commit_id)
    end


    # this is really recursive, but if fails with stackoverflow for larger repositories 
    def recursively_import id, repository
      parent_ids = System.execute_cmd!(git_parents_cmd).split(/\s+/)
      parents = parent_ids.drop(1).map do |parent_id|
        Commit.find_by(id: parent_id) || recursively_import(parent_id, repository)
      end
      commit = import(id, repository)
      parents.each do |p| 
        commit.parents << p unless commit.parents.include?(p)
      end
      commit
    end

    def import id, repository
      info = (`cd #{repository.dir};  git log -n 1 --pretty=\"%T %n%an %n%ae %n%ai %n%cn %n%ce %n%ci\" #{id}`).split(/\n/).map(&:strip)
      subject =  (`cd #{repository.dir};  git log -n 1 --pretty=\"%s\" #{id}`).gsub(/\n/,'')
      body = (`cd #{repository.dir};  git log -n 1 --pretty=\"%b\" #{id}`)
      Commit.create! id: id,  
        tree_id: info[0], 
        author_name: info[1], author_email: info[2], author_date: info[3], 
        committer_name: info[4], committer_email: info[5], committer_date: info[6], 
        subject: subject, body: body
    end

  end

end
