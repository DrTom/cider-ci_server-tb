#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Admin::BranchUpdateTriggersController< AdminController

  def create
    msg = begin 
            ActiveRecord::Base.transaction do
              branch = Branch.find(params[:branch_id])
              @branch_update_trigger = BranchUpdateTrigger.create! \
                branch: branch, definition_id: params[:definition_id]
              @branch_update_trigger.tags= params[:branch_update_trigger][:tags] \
                .split(",").map(&:strip).reject(&:blank?) \
                .map{|s| Tag.find_or_create_by(tag: s)}
              {success: %<The new trigger #{@branch_update_trigger} has been created!>}
            end
          rescue Exception => e
            {error: Formatter.exception_to_s(e)}
          end
    redirect_to admin_branch_update_triggers_path, flash: msg
  end

  def edit
    begin
      @branch_update_trigger = BranchUpdateTrigger.find params[:id]
    rescue Exception => e
      redirect_to :back, flash: {error: Formatter.exception_to_s(e)}
    end
  end

  def index
    @branch_update_triggers = BranchUpdateTrigger.all.joins(branch: :repository) \
      .reorder("repositories.name DESC", "branches.name DESC") \
      .page(params[:page])
  end

  def destroy
    begin
      @branch_update_trigger= BranchUpdateTrigger.find params[:id]
      @branch_update_trigger.destroy
      redirect_to admin_branch_update_triggers_path, flash: {success: %Q<The trigger #{@branch_update_trigger} has been removed >}
    rescue Exception => e
      redirect_to admin_branch_update_triggers_path, flash: {error: Formatter.exception_to_s(e)}
    end
  end

  def new
    @branch_update_trigger = BranchUpdateTrigger.new
    @branches = Branch.all
    @definitions = Definition.all
  end


  def update
    redirect_to admin_branch_update_triggers_path, flash: \
      begin
        @branch_update_trigger = BranchUpdateTrigger.find params[:id]
        @branch_update_trigger.update_attributes! \
          params.require(:branch_update_trigger).permit(:active)
        @branch_update_trigger.tags= params[:branch_update_trigger][:tags] \
          .split(",").map(&:strip).reject(&:blank?) \
          .map{|s| Tag.find_or_create_by(tag: s)}
        { success: %<The trigger #{@branch_update_trigger} has been updated!>}
      rescue Exception => e
        { error: Formatter.exception_to_s(e)}
      end
  end



end

