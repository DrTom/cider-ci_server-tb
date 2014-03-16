#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Admin::RepositoriesController < AdminController

  def permited_repository_params params
    if params[:repository]
      params[:repository].permit(:name,:origin_uri,:importance,:git_fetch_and_update_interval,:git_update_interval)
    else
      nil
    end
  end

  def create
    begin
      @repository = Repository.create! permited_repository_params(params)
      if defined? TorqueBox
        queue= TorqueBox.fetch('/queues/re_initialize_repository')
        queue.publish(@repository.attributes,encoding: :edn)
      end
      redirect_to admin_repositories_path, flash: {success: "The repository has been created. It will be initialized in the background."}
    rescue => e
      redirect_to new_admin_repository_path(params), flash: {error: e.to_s}
    end
  end

  def destroy
    begin
      @repository = Repository.find(params[:id])
      @repository.destroy!
      redirect_to admin_repositories_path, flash: {success: %Q<The repository "#{@repository}" has been destroyed.>}
    rescue Exception => e
      Rails.logger.error e
      redirect_to admin_repositories_path, flash: {error: Formatter.exception_to_s(e)}
    end
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def index
    @repositories = Repository.page(params[:page])
  end

  def new
    @repository = Repository.new permited_repository_params(params)
  end

  def update
    begin
      @repository = Repository.find(params[:id])
      @repository.update_attributes!  permited_repository_params(params)
      redirect_to admin_repository_path(@repository), flash: {success: "The repository has been updated."}
    rescue => e
      if @repository
        redirect_to edit_admin_repository_path(@repository), flash: {error: e.to_s}
      else
        redirect_to admin_repositories_path, flash: {error: e.to_s}
      end
    end
  end

  def update_git
    begin 
      raise "TODO"
    rescue Exception => e 
      redirect_to admin_repositories_path, flash: {error: Formatter.exception_to_s(e)}
    end

  end

  def re_initialize_git
    begin
      @repository = Repository.find(params[:repository_id])
      if defined? TorqueBox
        queue= TorqueBox.fetch('/queues/re_initialize_repository')
        queue.publish(@repository.attributes,encoding: :edn)
      end
      redirect_to admin_repository_path(@repository,anchor: @repository.transient_properties_id), flash: {success: "The repository will be re-initialized in the background."}
    rescue => e
      redirect_to admin_repositories_path, flash: {error: e.to_s}
    end
  end

  def show
    @repository = Repository.find(params[:id])
    @transient_properties = (CiderCI::Cache.get(@repository.transient_properties_id) or {}).deep_symbolize_keys
  end

end

