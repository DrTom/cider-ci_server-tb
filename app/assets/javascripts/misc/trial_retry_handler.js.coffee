#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

# takes care of the retry button in a task row shown in the execution page
# * disable button before sending request, i.e. right away
# * submit the row for immediate reloading on complete (either success of failure)
# * have the summary be scheduled for reloading 

$ -> 
  $(document).on "ajax:beforeSend","a.button.retry", (e)->
    $target = $(e.target)
    $target.addClass("disabled")
    $target.removeAttr("data-remote")
    $target.attr("href","#")

  $(document).on "ajax:complete","a.button.retry", (e)->
    $target = $(e.target)
    $target.html("OK")

