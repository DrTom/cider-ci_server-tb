#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

module System

  class ExecutionError < Exception
    def to_s
      "#{self.class} '#{super}'" 
    end
  end

  class << self

    def execute_cmd! cmd
      output = `#{cmd}`
      raise ExecutionError.new(cmd) if $?.exitstatus != 0
      output
    end

  end
end
