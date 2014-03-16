#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class ExecutorsApiV1::ScriptsController < ExecutorsApiV1Controller

  def permitted_params
    params.permit(:interpreter_command,:stderr,:stdout,:error,:exit_status,:started_at,:finished_at,:state)
  end

  def update
    Rails.logger.info params
    begin
      @script = Script.find(params.require :id)
      @script.update_attributes! permitted_params
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound => e
      render json: {error: "not-found"}, 
        status: :not_found
    rescue => e
      Rails.logger.error Formatter.exception_to_log_s(e)
      render json: {error: "Internal Server Error"}, 
        status: :internal_server_error
    end
  end

end
