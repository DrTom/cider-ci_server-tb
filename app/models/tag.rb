#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :executions
  has_and_belongs_to_many :branch_update_triggers
end
