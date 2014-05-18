unless window.Logger? then do ()->

  window.Logger= {}

  levels= ['error','info','debug']

  create= (params)->
    levelIndex=1
    namespace="Root"

    setLevel= (level)->
      if (_levelIndex= levels.indexOf(level)) >= 0
        levelIndex= _levelIndex
      else
        levelIndex= 1

    setNamespace= (_namespace)->
      namespace= _namespace ? "Root"

    setNamespace(params?.namespace)
    setLevel(params?.level)

    log=(level,messages)->
      #log_message= [moment().format(), namespace, level.toUpperCase(),JSON.stringify(messages)]
      messages.unshift [moment().format(), namespace, level.toUpperCase()]
      console[level].apply(console,messages)

    _logger=
      setLevel: setLevel
      error: (messages...)->
        log 'error', messages
      info: (messages...)->
        if levelIndex >= 1
          log 'info', messages
      debug: (messages...)->
        if levelIndex >= 2
          log 'debug', messages

    window.Logger[namespace] ||= _logger
    _logger

  create()
  Logger.create= create

