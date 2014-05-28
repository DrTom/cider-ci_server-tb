$ ->

  reloadEnabled= true

  logger= Logger.create namespace: 'Reloader', level: 'warn'

  reloadTimeout= $("#reload-page").data('reload-timeout') ? 5

  $("#reload-page").attr({'data-reloaded-at': moment().format()}) 


  setReplaceLock= ->
    $("#reload-page").attr({'data-not-replace-before': moment().add("seconds",3)})

  $(document).on "click", "form", ()-> setReplaceLock()
  $(document).on "change", "form", ()->setReplaceLock()

  checkIsAfterReplaceLock= ->
    unless $("#reload-page").attr("data-not-replace-before")?
      true
    else
      moment().isAfter($("#reload-page").attr("data-not-replace-before"))


  replaceAnimated= ($old,$new)->
    logger.debug "replacing animated"
    $old.fadeOut "slow", ->
      $new.hide()
      $(this).replaceWith($new)
      $new.fadeIn("slow")
      $new.trigger("replaced")

  replacePageWith= (data)->
    if checkIsAfterReplaceLock()
      $new= $("#reload-page",data)
      if not $("#reload-page").data("cache-tag")? 
        logger.debug "replacing without animation"
        $('#reload-page').replaceWith($new)
        $new.trigger("replaced")
        $("#reload-page").attr({'data-reloaded-at': moment().format()}) 
      else if $("#reload-page").data("cache-tag") isnt $new.data("cache-tag") 
        # something has changed, replace visually
        replaceAnimated $('#reload-page'), $new 
        $("#reload-page").attr({'data-reloaded-at': moment().format()}) 
      else
        logger.debug "no change, no replacing"


  reload= -> 

    reloadId= Math.random()
    $("#reload-page").attr("data-reload-id",reloadId)
    $.ajax
      url: window.location.href
      dataType: 'html'
      success: (data)->
        if $("#reload-page").attr("data-reload-id") == reloadId.toString()
          replacePageWith(data)
      complete: ()->
          $("#reload-page").removeAttr("data-reload-id")

  do reloadLoop= ->

    logger.debug "reloadLoop"

    reloadedAt= moment($("#reload-page").data('reloaded-at'))

    isAfterTimeout= moment().isAfter(reloadedAt.add('seconds',reloadTimeout))
    doesNotHaveReloadId= not $("#reload-page").attr("data-reload-id")?
    isAfterReplaceLock= checkIsAfterReplaceLock()

    logger.debug({
      isAfterTimeout: isAfterTimeout,
      doesNotHaveReloadId: doesNotHaveReloadId,
      isAfterReplaceLock: isAfterReplaceLock })

    if reloadEnabled and isAfterTimeout and isAfterReplaceLock and doesNotHaveReloadId
      reload()

    setTimeout reloadLoop, 1000

  window.Reloader={}
  window.Reloader.disable= ->
    reloadEnabled= false

