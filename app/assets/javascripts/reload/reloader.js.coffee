#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

$ ->

  DEFAULT_DELAY = 60
  CONCURRENCY_LIMIT = 5
  debug=false

  log= (msg)-> 
    if debug
      console.log _.flatten(["RELOADER #{moment().toISOString()}",msg],true)
    msg
    
  # sets the data-reload-at attribute to the epoch time stamp when the element
  # should be reloaded
  setReloadAt= -> 
    log "setReloadAt()" 
    _.chain($("[data-reload-enabled]:not([data-reload-at])").toArray())
      .map((e)->$(e)).map ($element) -> 
        delay= parseFloat($element.attr("data-reload-delay") ? DEFAULT_DELAY) 
        $element.attr("data-reload-at",moment().add(delay,"seconds").valueOf())
        $element
      .map(($e)->$e[0])
      .value()

  getReloadAt= (element)->
    parseFloat($(element).attr("data-reload-at"))

  # reloads the element if applicable; no matter what! e.g it is currently
  # reloading, or the CONCURRENCY_LIMIT is exhausted!  sets a data-reload-id
  # attribute which is uniquely used to identify the element in the callbacks
  reloadElement= (element)-> 
    log ["reloadElement",element]
    $element = $(element)

    return null unless $element.attr("data-reload-path")
    return null unless $element.attr("data-reload-partial")

    reloadId= Math.random()
    $element.attr("data-reload-id",reloadId)

    resetReloadTags= ($element) ->
      log ["resetReloadTags",$element]
      if $element or $element = $("[data-reload-id='#{reloadId}']") 
        $element.removeAttr('data-reload-id')
        $element.removeAttr('data-reload-at')

    replaceFun= ($old,$new)->
      log ["replacing",$old[0],$new[0]]
      $old.fadeOut "slow", ->
        $new.hide()
        $(this).replaceWith($new)
        $new.fadeIn("slow")
        $new.trigger("replaced")


    successFun= (data)->
      # don't do anything if we can't find the element by our internal reloadId
      if $old = $("[data-reload-id='#{reloadId}']") 
        old_cache_tag = $old.attr('data-reload-cache-tag')
        $new = $(data) 
        new_cache_tag = $new.attr('data-reload-cache-tag')
        if old_cache_tag and new_cache_tag and old_cache_tag is new_cache_tag 
          # don't replace; just reset for starting reload process all over again
          resetReloadTags $old
        else
          $data = $(data)
          log ["replacing", $old, $data]
          replaceFun $old, $data
          $data.trigger("reloaded")
          
    ajax= $.ajax
      url: $element.attr("data-reload-path")
      dataType: "html"
      headers: 
        partial: $element.attr("data-reload-partial")
      success: successFun
      error: -> resetReloadTags()
      complete: (jqXHR,status)-> log ["ajax complete",status,jqXHR]

    log ["ajax:",ajax]

    $element[0]


  # reloads the pending elements (those with data-reload-at < now);
  # respects the CONCURRENCY_LIMIT
  reloadPending= ->
    slots = CONCURRENCY_LIMIT - $.active
    log ["reloadPending(), slots: ",slots]
    return [] if slots <= 0

    log_array_wrapped= (msg,fun)->
      return ( -> ) unless debug
      (a)->
        (log ["reloadPending chain #{msg}", _.map(a, (e)->
          if fun?
            fun(e)
          else e[0] 
        )])

    _.chain($("[data-reload-enabled][data-reload-at]:not([data-reload-id])").toArray())
      .map((e)->$(e))
      .tap(log_array_wrapped "selected")
      .filter(($e)-> 
        now = moment().valueOf()
        getReloadAt($e) <= now)
      .tap(log_array_wrapped "filtered")
      .sortBy( ($e)-> getReloadAt($e) )
      .tap(log_array_wrapped "sorted")
      .tap(log_array_wrapped "sorted getSortedAt", ($e)-> getReloadAt($e) )
      .take(slots)
      .tap(log_array_wrapped "taken")
      .map((e)-> reloadElement(e))
      .value()


  reloadLoop=( ->
    active=false
    sleep=1*1000
    innerLoop= ->
      if active
        setReloadAt()
        reloadPending()
        setTimeout innerLoop, sleep
    {
    isActive: -> active
    sleep: sleep 
    start: -> 
      unless active
        active = true
        innerLoop() 
    stop: (-> active=false) }
    )()

  reloadLoop.start()

  window.Reloader=
    setReloadAt: setReloadAt
    reloadElement: reloadElement
    reloadPending: reloadPending
    reloadLoop: reloadLoop
    debug: (v)-> debug = v if v; debug


 
