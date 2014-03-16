#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Admin::ServerSettingsController < AdminController

  def edit
    @server_settings = ServerSettings.find 
  end

  def update
    @server_settings = ServerSettings.find
    redirect_to edit_admin_server_settings_path(@server_settings), flash: \
      begin
        @server_settings.update_attributes! params.require(:server_settings).permit!
        { success: %<The server settings have been updated!>}
    rescue Exception => e
      { error: Formatter.exception_to_s(e)}
    end
  end

end
