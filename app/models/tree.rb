#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Tree < ActiveRecord::Base
  self.primary_key = 'id'
  has_many :commits
  has_many :executions

  default_scope{order(:id)}

end
