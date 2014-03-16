#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Admin::DefinitionsController < AdminController

  def permited_definition_params params
    if params[:definition]
      params[:definition].permit(:name,:specification)
    else
      nil
    end
  end

  def create 
    rescue_path= new_admin_definition_path(definition: {name: params[:definition].try(:[],'name')}, 
                                           specification: {data: params[:specification].try(:[],'data')})
    Fun.wrap_exception_with_redirect self, rescue_path do
      @specification = Specification.find_or_create_by_data! YAML.load(params[:specification][:data])
      @definition = Definition.create! permited_definition_params(params).merge({specification: @specification})
      redirect_to admin_definitions_path, flash: {success: "A new Definition has been created."}
    end
  end

  def destroy
    Fun.wrap_exception_with_redirect self, admin_definitions_path do
      @definition = Definition.find params[:id]
      @definition.destroy 
      redirect_to admin_definitions_path, flash: \
        {success: %Q<The definition "#{@definition}" has been destroyed.>}
    end
  end

  def edit 
    @definition = Definition.find params[:id] 

    @previous_data = params[:specification].try(:[],'data')
    @previous_name = params[:definition].try(:[],'name')

    @definition.name = @previous_name if @previous_name
  end

  def index
    @definitions = Definition.page(params[:page])
  end



  def new
    @previous_data = params[:specification].try(:[],'data')
    @previous_name = params[:definition].try(:[],'name')

    @definition = Definition.new(specification: 
                                 if (id = params[:definition_id])
                                   Definition.find(id).specification
                                 else
                                   Specification.new  
                                 end)

    @other_definitions = Definition.reorder(:name)
  end

  def update
    rescue_path=edit_admin_definition_path(definition: {name: params[:definition].try(:[],'name')}, 
                                           specification: {data: params[:specification].try(:[],'data')})
    Fun.wrap_exception_with_redirect self, rescue_path do
      ActiveRecord::Base.transaction do
        @definition = Definition.find params[:id]
        @specification = Specification.find_or_create_by_data! YAML.load(params[:specification][:data])
        @definition.update_attributes! permited_definition_params(params).merge({specification: @specification})
        redirect_to admin_definitions_path, flash: {success: %Q<The definition has been updated.>}
      end
    end
  end

end
