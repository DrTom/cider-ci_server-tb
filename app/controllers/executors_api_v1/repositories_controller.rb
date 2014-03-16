#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class ExecutorsApiV1::RepositoriesController < ExecutorsApiV1Controller

  def get_git_file
    @repository = Repository.find params[:id]
    @absolute_path = [@repository.dir,params[:path]].join("/")

    if not File.exists? @absolute_path
      Rails.logger.error ["git file not found", @absolute_path]
      render file: Rails.root.join("public","404.html"), status: :not_found
    else
      send_file @absolute_path
    end
  end

end
