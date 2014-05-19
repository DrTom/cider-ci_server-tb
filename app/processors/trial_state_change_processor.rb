#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

if defined? TorqueBox::Messaging::MessageProcessor

  class TrialStateChangeProcessor < TorqueBox::Messaging::MessageProcessor
    def on_message(msg)
      Rails.logger.info ["Received trial state change update message: ", msg]

      begin 

        trial_attributes= msg.deep_symbolize_keys

        Trial.find_by(id: trial_attributes[:id]).task.instance_eval do
          check_and_retry!
          update_state!
        end

      rescue Exception => e
        Rails.logger.error e
        Rails.logger.error ["Failed to process trial state change message:", msg]
      end

    end
  end
end
