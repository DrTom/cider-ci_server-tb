#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.


class TrialScriptsSweeper
  def run
    Rails.logger.info  "Sweeping #{Trial.with_scripts_to_clean.count} trials to clean scripts" 
    Trial.with_scripts_to_clean.find_in_batches do |batch|
      batch.each do |trial|
        trial.update_attributes! scripts: []
      end
    end
  end
end
