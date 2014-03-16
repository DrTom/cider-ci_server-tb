#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class ExecutionCacheSignature < ActiveRecord::Base
  self.primary_key= :execution_id 
  belongs_to :execution
end
