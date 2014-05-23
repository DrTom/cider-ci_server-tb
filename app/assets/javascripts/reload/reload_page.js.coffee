$ ->

  logger= Logger.create namespace: 'Reloader', level: 'info'

  reloadDisabled= false

  reloadTimeout= $("#reload-page").data('reload-timeout') ? 5

  logger.info reloadTimeout: reloadTimeout

  skipNextReload= false

  # doesn't work after replacement
   
  $("form").change (args...)->
    logger.debug "skipNextReload"
    skipNextReload= true

  $("form").click (args...)->
    logger.debug "skipNextReload"
    skipNextReload= true

  replaceAnimated= ($old,$new)->
    logger.debug "replacing animated"
    $old.fadeOut "slow", ->
      $new.hide()
      $(this).replaceWith($new)
      $new.fadeIn("slow")
      $new.trigger("replaced")


  reload= -> 
    logger.debug "reload invoked"

    if skipNextReload or reloadDisabled
      logger.debug "skipping reload"
      skipNextReload= false
      setTimeout(reload , 3 * reloadTimeout * 1000)

    else
      $.ajax
        url: window.location.href
        dataType: 'html'
        success: (data)->
          $new= $("#reload-page",data)
          if not $("#reload-page").data("cache-tag")? 
            logger.debug "replacing without animation"
            $('#reload-page').replaceWith($new)
            $new.trigger("replaced")
          else if $("#reload-page").data("cache-tag") isnt $new.data("cache-tag") 
            # something has changed, replace visually
            replaceAnimated $('#reload-page'), $new 
          else
            logger.debug "no change, no replacing"

          setTimeout(reload, reloadTimeout * 1000)

  if $("#reload-page")[0]? 
    logger.debug "setting timeout for initial reload"
    setTimeout(reload, reloadTimeout * 1000)


  window.Reloader={}
  window.Reloader.disable= ->
    reloadDisabled= true


