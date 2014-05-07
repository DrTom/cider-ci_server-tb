#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Attachment < ActiveRecord::Base
  belongs_to :trial, touch: true

  scope :out_of_retention_time, lambda{
    where(%[ attachments.created_at <
      (now() - interval '#{TimeoutSettings.find.attachment_retention_time_hours} Hours')])}

end

