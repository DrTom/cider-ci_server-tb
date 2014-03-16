#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Admin::TimeoutSettingsController < AdminController

  def edit
    @timeout_settings = TimeoutSettings.find 
  end

  def update
    @timeout_settings = TimeoutSettings.find
    redirect_to edit_admin_timeout_settings_path(@timeout_settings), flash: \
      begin
        @timeout_settings.update_attributes! params.require(:timeout_settings).permit!
        { success: %<The timeout settings have been updated!>}
    rescue Exception => e
      { error: Formatter.exception_to_s(e)}
    end
  end

end
