#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class WorkspaceController < ApplicationController

  before_action do
    if not admin_party? and not current_user
      redirect_to public_path, flash: {error: "You must be signed in to access this resource!"}
    end
  end


  helper_method \
    :branch_names_filter, 
    :commit_text_search_filter,
    :is_branch_head_filter,
    :execution_tags_filter,
    :repository_names_filter, 
    :with_branch_filter,
    :with_execution_filter

  def execution_tags_filter 
    params.try('[]',"execution").try('[]',:tags).try(:nil_or_non_blank_value) \
      .split(",").map(&:strip).reject(&:blank?) rescue []
  end

  def repository_names_filter 
    params.try('[]',"repository").try('[]',:names).try(:nil_or_non_blank_value) \
      .split(",").map(&:strip).reject(&:blank?) rescue []
  end

  def branch_names_filter
    params.try('[]',"branch").try('[]',:names).try(:nil_or_non_blank_value) \
      .split(",").map(&:strip).reject(&:blank?) rescue []
  end

  def commit_text_search_filter
    params.try('[]',"commit").try('[]',:text).try(:nil_or_non_blank_value)
  end

  def is_branch_head_filter
    params["is_branch_head"] or false
  end

  def with_branch_filter
    params["with_branch"] or false
  end

  def with_execution_filter
    params["with_execution"] or false
  end



  def dashboard
    @executions = Execution.reorder(created_at: :desc).limit(10)

    @finished_trials = Trial.finished
    @trials_in_exeuction = Trial.in_execution.limit(5)
    @queued_trials = Trial.to_be_dispatched.limit(5)

    @branches = Branch.joins(:current_commit).reorder("commits.committer_date DESC").limit(10)

    @executors = ExecutorWithLoad.reorder(:name).limit(10)
  end

  def branch_heads
    @branches = Branch.reorder(updated_at: :desc).page(params[:page])
  end

end
