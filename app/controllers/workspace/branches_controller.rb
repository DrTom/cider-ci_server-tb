#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Workspace::BranchesController < WorkspaceController 

  def show
    @branch = Branch.find(params[:id])
    @commits = @branch.current_commit.with_ancestors.page(params[:page])
  end

  def names
    @branches= if (term= params[:term]).blank?
        Branch.reorder(name: :asc).page
      else
        Branch.reorder(name: :asc).where("name ilike ?",term<<'%')
      end
    @branches=@branches.limit(25)
    if @branches.count < 25
      render json: @branches.pluck(:name)
    else
      render json: []
    end
  end


end
