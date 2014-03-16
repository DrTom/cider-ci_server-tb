#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

if defined? TorqueBox::Messaging::MessageProcessor

  class TrialStateChangeProcessor < TorqueBox::Messaging::MessageProcessor
    def on_message(msg)
      Rails.logger.info ["Received trial state change update message: ", msg]

      trial_attributes= msg.deep_symbolize_keys

      ExceptionHelper.with_log_and_reraise do
        Trial.find_by(id: trial_attributes[:id]).task.instance_eval do
          check_and_retry!
          update_state!
        end
      end

    end
  end
end
