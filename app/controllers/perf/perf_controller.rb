#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Perf::PerfController < ApplicationController

  before_action do
    @_lookup_context.prefixes<< "/perf"
    @_lookup_context.prefixes<< "/perf/partials"
    @_lookup_context.prefixes<< "/perf/caching"
  end


  def root
    render 'perf/root'
  end
end
