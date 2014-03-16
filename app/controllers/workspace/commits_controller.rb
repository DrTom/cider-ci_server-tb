#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Workspace::CommitsController < WorkspaceController 

  def index
    @link_params = params.slice(:branch,:commit_text,:page,:repository)

    @commits = Commit.distinct.page(params[:page])

    @commits = @commits.joins(:branches) \
      .where(branches:{name: branch_names_filter}) unless branch_names_filter.empty?

    @commits = @commits.joins(branches: :repository) \
      .where(repositories: {name: repository_names_filter}) unless repository_names_filter.empty?

    @commits = @commits.basic_search(commit_text_search_filter,false) if commit_text_search_filter

    @commits = @commits.joins(:head_of_branches) if is_branch_head_filter

    @commits = @commits.joins(tree: :executions) if with_execution_filter

    @commits = @commits.reorder(committer_date: :desc, depth: :desc)

    @commits= @commits.includes(:executions)
    @commits= @commits.includes(:commit_cache_signature)
    @commits= @commits.includes(:repositories)

    @commits_cache_signatures = CommitCacheSignature \
      .where(%[ commit_id IN (#{@commits.map(&:id).map{|id| "'#{id}'"}.join(",").non_blank_or("NULL")}) ])

    @commits_cache_signatures_array= @commits_cache_signatures.map do |cs| 
      [cs.commit_id,cs.branches_signature,cs.repositories_signature,cs.executions_signature]
    end

    if partial= request.headers['PARTIAL']
      render partial: partial, layout: false
    else
      render
    end

  end

  def show
    @commit = Commit.find params[:id]
    if partial= request.headers['PARTIAL']
      render partial: partial, layout: false, locals: {execution: @execution}
    else
      render
    end
  end

end

