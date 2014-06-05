#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Workspace::TagsController < WorkspaceController 

  def index

    @tags= if (term= params[:term]).blank?
        Tag.reorder(tag: :asc).page
      else
        Tag.reorder(tag: :asc).where("tag ilike ?",term<<'%')
      end
    @tags=@tags.limit(25)

    if @tags.count < 25
      render json: @tags.pluck(:tag)
    else
      render json: []
    end

  end
  
end
