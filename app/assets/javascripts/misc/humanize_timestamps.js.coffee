#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

$ ->

  $("body").on "replaced", (event) -> 
    humanizeTimestamps($(event.target))
    humanizeDuration($(event.target))


  humanizeDuration= ($parent)->
    ($parent ? $("body")).find(".humanize-duration").toArray().map((el)->$(el)).forEach ($element)->
      seconds= parseFloat $element.attr("data-duration")
      duration = moment.duration(seconds * 1000)
      $element.html "about " + duration.humanize()

  humanizeTimestamps=  ($parent)->

    ($parent ? $("body")).find(".humanize-timestamp").toArray().map((el)->$(el)).forEach ($element)->

      #console.log ["humanizing",$element]

      at = moment($element.attr("data-at"))
      humanDist = at.fromNow()
      html = humanDist

      # add "on" if not today
      if at.format("YYYY MM DD") isnt moment().format("YYYY MM DD")
        html += " on #{at.format('dddd')}" 
        # add day of month if not same week and month
        if at.format("YYYY MM W") isnt moment().format("YYYY MM W")
          html += ", #{at.format('Do')}"
          # add month if not same
          if at.format("YYYY MM") isnt moment().format("YYYY MM")
            html += " #{at.format('MMMM')}"
            # and finaly the year
            if at.format("YYYY") isnt moment().format("YYYY")
              html += " #{at.format('YYYY')}"

      $element.html html

  humanizeLoop = ->
    humanizeTimestamps()
    humanizeDuration()
    setTimeout humanizeLoop, 10 * 1000

  humanizeLoop()

