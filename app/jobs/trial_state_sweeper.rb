#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.


class TrialStateSweeper

  def run

    Rails.logger.info  "Sweeping trials wrt. state" 

    Trial.in_execution_timeout.each do |trial|
      ExceptionHelper.with_log_and_supress! do
        trial.update_attributes!  state: 'failed', error: "execution timeout"
      end
    end

    # we avoid callbacks so there will be no automatic retry
    %w(in_dispatch_timeout in_not_finished_timeout).each do |timeout_method|
      Trial.send(timeout_method).each do |trial|
        ExceptionHelper.with_log_and_supress! do
          trial.update_columns  \
            state: 'failed', error: timeout_method, updated_at: 'now()'
        end
        trial.reload.task.update_state!
      end
    end


  end

end
