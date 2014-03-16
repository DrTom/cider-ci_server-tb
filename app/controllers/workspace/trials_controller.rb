#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Workspace::TrialsController < WorkspaceController 

  def get_attachment
    @attachment = Attachment.find_by trial_id: params.require(:id), path: params.require(:path)
    send_data Base64.decode64(@attachment.content), type: @attachment.content_type, filename: @attachment.path, disposition: params['disposition']
  end

  def destroy
    begin
      @trial = Trial.find(params[:id])
      @execution= @trial.task.execution
      @trial.destroy
      redirect_to workspace_execution_path(@execution), flash: {success: "The trial has been destroyed"}
    rescue Exception => e
      redirect_to workspace_dashboard_path, flash: {error: Formatter.exception_to_s(e)}
    end
  end

  def index
    @trials = Trial.page(params[:page])

    @selected_state = params[:state]
    @trials = case @selected_state
              when "all"
                @trials
              when "executing"
                @trials.in_execution
              when "finished"
                @trials.finished
              when "pending"
                @trials.to_be_dispatched
              else
                @trials
              end
  end


  def set_failed 
    begin
      @trial = Trial.find(params[:id])
      @trial.update_attributes! state: "failed"
      redirect_to workspace_execution_path(@trial.task.execution), flash: {success: "The trail has been marked as failed."}
    rescue Exception => e
      redirect_to (@trial ? workspace_trial_path(@trial) : workspace_dashboard_path), \
        flash: {error: Formatter.exception_to_s(e)}
    end
  end

  def show
    @trial = Trial.find params[:id]
    @scripts = @trial.scripts
  end


end
