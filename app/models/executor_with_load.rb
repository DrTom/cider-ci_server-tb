#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class ExecutorWithLoad < Executor
  self.table_name= :executors_with_load

  belongs_to :executor, primary_key: 'id', foreign_key: 'id'

  scope :dispatch_order, lambda{
    where("executors_with_load.relative_load < 1") \
    .reorder(relative_load: :asc)
  }
end
