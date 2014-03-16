#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

module Formatter
  class << self

    def exception_to_s e

      case Rails.env
      when "development"
        e.message.to_s + "\n\n" + 
          e.backtrace.select{|l| l =~ Regexp.new(Rails.root.to_s)}.join("\n") 
        # + "\n\n" + e.backtrace.join("\n") 
      else
        e.message.to_s
      end
    end

    def exception_to_log_s e
      e.message.to_s + "\n" + 
        e.backtrace.select{|l| l =~ Regexp.new(Rails.root.to_s)}
      .reject{|l| l =~ Regexp.new(Rails.root.join("vendor").to_s)}.join("\n") 
    end


    def include_realative_url_root url, path
      idx= (url =~ Regexp.new(path)) 
      "#{url[0..(idx-1)]}#{Rails.application.config.relative_url_root}#{url[idx..url.size]}"
    end

  end
end
