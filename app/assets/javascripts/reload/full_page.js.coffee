#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

$ -> 

  DEFAULT_DELAY = 60

  if $("body[data-reload-suppress-partial]").size() > 0
    $("[data-reload-enabled]").toArray().map((e)->$(e)).forEach ($element)->
      $element.removeAttr("data-reload-enabled")

  if $('body[data-reload-full-page]').size() > 0
    delay = parseFloat( $('body').attr("data-reload-delay") ? DEFAULT_DELAY) 
    setTimeout( ( -> window.location.reload()) , delay * 1000)


