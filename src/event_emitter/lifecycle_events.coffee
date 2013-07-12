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

fire = (eventName, arg) ->
  return unless handlers = @_batman.get(eventName)
  result = true

  for {options, callback} in handlers
    continue if options?.if and !options.if.call(this, arg)
    continue if options?.unless and options.unless.call(this, arg)
    result = false if callback.call(this, arg) == false

  return result
