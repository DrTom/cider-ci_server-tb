#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

module Fun
  class << self

    def uuid_hash s
      uuid_ns = UUIDTools::UUID_URL_NAMESPACE
      UUIDTools::UUID.sha1_create(uuid_ns, s).to_s
    end


    def wrap_exception_with_redirect controller, redirect_path
      begin
        yield 
      rescue Exception => e
        Rails.logger.error Formatter.exception_to_log_s(e)
        controller.redirect_to redirect_path, flash: {error:  Formatter.exception_to_s(e)}
      end
    end

    def supress_and_log_exception
      begin 
        yield
      rescue Exception => e
        Rails.logger.warn Formatter.exception_to_log_s(e)
      end
    end

  end
end
