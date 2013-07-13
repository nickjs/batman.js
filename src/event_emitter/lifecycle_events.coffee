Batman.LifecycleEvents =
  initialize: ->
    @::fireLifecycleEvent = fire

  lifecycleEvent: (eventName, normalizeFunction) ->
    beforeName = "before#{Batman.helpers.camelize(eventName)}"
    afterName = "after#{Batman.helpers.camelize(eventName)}"

    addCallback = (eventName) ->
      (callbackName, options) ->
        switch Batman.typeOf(callbackName)
          when 'String'
            callback = -> @[callbackName].apply(this, arguments)
          when 'Function'
            callback = callbackName
          when 'Object'
            callback = options
            options = callbackName

        options = normalizeFunction?(options) || options

        target = @prototype || this
        Batman.initializeObject(target)

        handlers = target._batman[eventName] ||= []
        handlers.push(options: options, callback: callback)

    @[beforeName] = addCallback(beforeName)
    @::[beforeName] = addCallback(beforeName)

    @[afterName] = addCallback(afterName)
    @::[afterName] = addCallback(afterName)

fire = (eventName, args...) ->
  return unless handlers = @_batman.get(eventName)

  for {options, callback} in handlers
    continue if options?.if and !options.if.apply(this, args)
    continue if options?.unless and options.unless.apply(this, args)
    return false if callback.apply(this, args) == false
