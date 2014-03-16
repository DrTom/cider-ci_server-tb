#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class AdminController < ApplicationController

  before_action do
    unless admin? 
      redirect_to public_path, flash: {error: "This resource requires adminstrator privileges!"}
    end
  end

  def dispatch_trials
    begin 
      Executor.enabled.each{|executor| executor.ping}
      dispatched_trials = DispatchService.new.dispatch_trials
      redirect_to :back, flash: {success: "dipatched #{dispatched_trials}"}
    rescue Exception => e
      redirect_to :back, flash: {error: Formatter.exception_to_s(e)}
    end
  end

end
