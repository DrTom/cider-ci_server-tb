#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class AttachmentsSweeper
  def run
    Rails.logger.info  "Sweeping Attachments" 
    Attachment.out_of_retention_time.each do |attachment|
      ExceptionHelper.with_log_and_supress! do
        attachment.trial.touch
        attachment.destroy
      end
    end
  end
end
