#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Workspace::SessionsController < WorkspaceController
  def edit
  end

  def update
    session[:mini_profiler_enabled]= params[:mini_profiler_enabled] == "1"
    redirect_to edit_workspace_session_path, flash: {success: "The session parameters have been set."}
  end
end
