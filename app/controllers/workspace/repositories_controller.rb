#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Workspace::RepositoriesController < WorkspaceController 

  def index
    @repositories = Repository.all
  end

  def show
    @repository = Repository.find(params[:id])
  end

  def get_git_file
    @repository = Repository.find params[:id]
    @absolute_path = File.absolute_path(@repository.dir + params[:path])

    if not File.exists? @absolute_path
      render file: Rails.root.join("public","404.html"), status: :not_found
    else
      send_file @absolute_path
    end

  end


  def names
    @repositories= if (term= params[:term]).blank?
        Repository.reorder(name: :asc).page
      else
        Repository.reorder(name: :asc).where("name ilike ?",term<<'%')
      end
    @repositories=@repositories.limit(25)
    if @repositories.count < 25
      render json: @repositories.pluck(:name)
    else
      render json: []
    end
  end

end
