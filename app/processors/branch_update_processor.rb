#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

if defined? TorqueBox::Messaging::MessageProcessor
  class BranchUpdateProcessor < TorqueBox::Messaging::MessageProcessor
    Rails.logger.info "INITIALIZING PROCESSOR"
    def on_message(msg)
      Rails.logger.info ["Received branch update message: ", msg]

      branch = msg.deep_symbolize_keys

      BranchUpdateTrigger.active \
        .where(branch_id: branch[:id]).each do |branch_update_trigger| 

        Rails.logger.info "Creating new execution on behalf of branch update" 

        ExceptionHelper.with_log_and_reraise do

          @commit = Commit.find(branch[:current_commit_id])

          @execution = Execution.create! \
            specification: branch_update_trigger.definition.specification, 
            definition_name: branch_update_trigger.definition.name,
            tree_id: @commit.tree_id

          @execution.tags= branch_update_trigger.tags

          @execution.create_tasks_and_trials

        end
      end
    end
  end
end
