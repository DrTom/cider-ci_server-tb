#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Workspace::ExecutionsController < WorkspaceController 

  before_action do
    @_lookup_context.prefixes<< "workspace/commits"
    @_lookup_context.prefixes<< "workspace/tasks"
  end


  def create
    Fun.wrap_exception_with_redirect(self,:back) do 
      ActiveRecord::Base.transaction do
        @commit = Commit.find params[:commit_id]
        @definition = Definition.find(params[:definition_id])
        @execution = Execution.create! ({specification: @definition.specification, 
                                         definition_name: @definition.name,
                                         tree_id: @commit.tree_id}.merge(params.require(:execution).permit(:priority)))
        params[:execution][:tags].split(",").map(&:strip).reject(&:blank?).each do |tag|
          @execution.tags << Tag.find_or_create_by(tag: tag) rescue nil
        end
      end
      Execution.create_tasks_and_trials_for @execution.id
      redirect_to workspace_execution_path(@execution), flash: {success: "The execution has been created. Tasks and trials will be created in the background."}
    end
  end


  def destroy
    @execution = Execution.find params[:id]
    begin
      ActiveRecord::Base.transaction do
        @execution.delete
      end
      redirect_to workspace_commits_path, flash: {success: "The execution #{@execution} has been destroyed."}
    rescue Exception => e
      path =  if @execution and not @execution.destroyed?
                workspace_execution_path(@execution) 
              else
                workspace_dashboard_path
              end
      redirect_to path , flash: {error: Formatter.exception_to_s(e)}
    end
  end

  def edit
    @execution = Execution.find params[:id]
  end

  def index
    @link_params = params.slice(:branch,:page,:repository,:execution)
    @executions = Execution.reorder(created_at: :desc).page(params[:page])
    @executions= @executions.joins({commits: :branches}) \
      .where(branches:{name: branch_names_filter}) unless branch_names_filter.empty?
    @executions= @executions.joins({commits: {branches: :repository}}).distinct \
      .where(repositories: {name: repository_names_filter}) unless repository_names_filter.empty?
    @executions= @executions.joins(:tags).where(tags: {tag: execution_tags_filter}) if execution_tags_filter.count > 0


    @execution_cache_signatures = ExecutionCacheSignature \
      .where(%[ execution_id IN (#{@executions.map(&:id).map{|id| "'#{id}'"}.join(",").non_blank_or("NULL")}) ])\
      .select(:execution_id,:stats_signature,:commits_signature,:branches_signature,:tags_signature)

    if partial= request.headers['PARTIAL']
      render partial: partial, layout: false
    else
      render
    end
  end


  def new
    @execution = Execution.new
    @commit = Commit.find params[:commit_id]
    @branches = Branch.where(current_commit_id: @commit.with_descendants.pluck(:id))
    @definitions = Definition.all
  end

  def show
    @execution = Execution.find params[:id]
    set_and_filter_tasks params
    if partial= request.headers['PARTIAL']
      render partial: partial, layout: false, locals: {execution: @execution}
    else
      render
    end
  end

  def retry_failed
    @execution = Execution.find params[:id]
    @execution.tasks.where(state: 'failed').each(&:create_trial)
    redirect_to workspace_execution_path(@execution), flash: {success: "The failed tasks are scheduled for retry!"}
  end

  def tasks
    @execution = Execution.find params[:id]
    set_and_filter_tasks(params)
    if partial= request.headers['PARTIAL']
      render partial: partial, layout: false, locals: {execution: @execution, tasks: @tasks}
    else
      render 
    end
  end

  def update
    begin 
      @execution = Execution.find(params[:id])
      @execution.tags= params[:execution][:tags] \
        .split(",").map(&:strip).reject(&:blank?) \
        .map{|s| Tag.find_or_create_by(tag: s)}
      @execution.update_attributes! params.require(:execution).permit(:priority)
      redirect_to workspace_execution_path(@execution), flash: {success: "The execution has been updated."}
    rescue Exception => e
      redirect_to edit_workspace_execution_path(@execution), flash: {error: e}

    end
  end


  def set_and_filter_tasks params
    @tasks_select_condition = (params[:tasks_select_condition] || :with_failed_trials).to_sym
    @page=params[:page]
    @tasks = @execution.tasks
    @tasks = case @tasks_select_condition
             when :with_failed_trials 
               @tasks.with_failed_trials
             when :failed
               @tasks.where(state: 'failed')
             else
               @tasks
             end
    @tasks= @tasks.reorder(:name).page(params[:page])
  end

end
