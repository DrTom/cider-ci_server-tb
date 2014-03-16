#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

module Constants 
  EXECUTION_STATES = %w(failed success executing pending)
  UPDATE_BRANCH_TOPIC_NAME = '/topics/branch_updates'
  class << self
    def TRIAL_STATES 
      @trial_states ||= %w(pending dispatching executing failed success).sort
    end
  end
end
