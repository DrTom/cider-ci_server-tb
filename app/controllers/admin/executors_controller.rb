#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Admin::ExecutorsController < AdminController


  def create 
    begin
      @executor = Executor.create! processed_params 
      redirect_to admin_executors_path, flash: {success: %< The new executor "#{@executor}" has been created.>}
    rescue Exception => e
      redirect_to new_admin_executor_path(params), flash: {error: Formatter.exception_to_s(e)}
    end
  end

  def destroy
    begin 
      @executor = Executor.find params[:id]
      @executor.destroy
      redirect_to admin_executors_path, flash: {success: %<The executor "#{@executor}" has been destroyed>}
    rescue Exception => e
      redirect_to admin_executors_path, flash:{error: Formatter.exception_to_s(e)}
    end
  end

  def edit
    @executor = Executor.find params[:id]
  end

  def index
    @executors = ExecutorWithLoad.page(params[:page])
  end

  def new 
    @executor = Executor.new processed_params
  end

  def update
    begin
      @executor =  Executor.find params[:id]
      @executor.update_attributes! processed_params 
      redirect_to admin_executors_path,  flash: {success: "The executor has been updated."} 
    rescue Exception => e
      redirect_to admin_executors_path,  flash: {error: Formatter.exception_to_s(e)} 
    end
  end

  def ping
    Executor.find(params[:id]).ping
    redirect_to admin_executors_path
  end

  def processed_params 
    traits = params[:executor].try(:[],:traits).try(:split,',').try(:map){|s|s.strip}.try(:sort)
    params[:executor].try(:permit,:name,:host,:port,:ssl,:server_host,:server_port,:max_load,:enabled,:traits).try(:merge,{traits: traits})
  end

end
