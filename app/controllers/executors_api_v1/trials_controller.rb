#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class ExecutorsApiV1::TrialsController < ExecutorsApiV1Controller

  def update
    begin
      update_params = params.require(:trial).slice(:error,:state,:stderr,:stdout,:started_at,:finished_at,:scripts)
      @trial = Trial.find(params.require :id).update_attributes! update_params.permit!
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound => e
      render json: {error: "not-found"}, status: :not_found
    rescue Exception => e
      Rails.logger.error Formatter.exception_to_log_s(e)
      render json: {error: Formatter.exception_to_s(e)}, status: 422
    end
  end

  def put_attachment
    begin 
      @attachment = Attachment.find_or_create_by!( trial_id: params.require(:id), 
                                                  path: params.require(:path)) \
                              .update_attributes!(content_type: request.env['CONTENT_TYPE'], 
                                                  content_length: request.env['CONTENT_LENGTH'],
                                                  content: Base64.encode64(request.body.read),
                                                  path: params.require(:path))
      render json: {}, status: :no_content
    rescue Exception => e
      Formatter.exception_to_log_s(e).tap do |errs| 
        Rails.logger.error errs
        render json: {error: errs}, status: 422
      end
    end
  end

end
