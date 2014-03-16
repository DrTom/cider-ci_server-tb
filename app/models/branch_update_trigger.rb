#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class BranchUpdateTrigger < ActiveRecord::Base

  self.primary_key = :id

  belongs_to :definition
  belongs_to :branch

  has_and_belongs_to_many :tags

  scope :active, lambda{ where active: true  }

end
