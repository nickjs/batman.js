#= require_tree ../hash

class Batman.RenderCache extends Batman.Hash
  maximumLength: 4
  constructor: ->
    super
    @keyQueue = []

  viewForOptions: (options) ->
    if Batman.config.cacheViews || options.cache || options.viewClass::cache
      @getOrSet options, =>
        @_newViewFromOptions(Batman.extend {}, options)
    else
      @_newViewFromOptions(options)

  _newViewFromOptions: (options) -> new options.viewClass(options)

  @wrapAccessor (core) ->
    cache: false
    get: (key) ->
      result = core.get.call(@, key)
      # Bubble the result up to the top of the queue
      @_addOrBubbleKey(key) if result
      result

    set: (key, value) ->
      result = core.set.apply(@, arguments)
      result.set 'cached', true
      @_addOrBubbleKey(key)
      @_evictExpiredKeys()
      result

    unset: (key) ->
      result = core.unset.apply(@, arguments)
      result.set 'cached', false
      @_removeKeyFromQueue(key)
      result

  equality: (incomingOptions, storageOptions) ->
    return false unless Object.keys(incomingOptions).length == Object.keys(storageOptions).length
    for key of incomingOptions when !(key in ['view'])
      return false if incomingOptions[key] != storageOptions[key]
    return true

  reset: ->
    for key in @keyQueue.slice(0)
      @unset(key)
    return

  _addOrBubbleKey: (key) ->
    @_removeKeyFromQueue(key)
    @keyQueue.unshift key

  _removeKeyFromQueue: (key) ->
    for queuedKey, index in @keyQueue
      if @equality(queuedKey, key)
        @keyQueue.splice(index, 1)
        break
    key

  _evictExpiredKeys: ->
    if @length > @maximumLength
      currentKeys = @keyQueue.slice(0)
      for i in [@maximumLength...currentKeys.length]
        key = currentKeys[i]
        if !@get(key).isInDOM()
          @unset(key)
    return
