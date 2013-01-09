# `Batman.typeOf` returns a string that contains the built-in class of an object
# like `String`, `Array`, or `Object`. Note that only `Object` will be returned for
# the entire prototype chain.
Batman.typeOf = (object) ->
  return "Undefined" if typeof object == 'undefined'
  _objectToString.call(object).slice(8, -1)

# Cache this function to skip property lookups.
_objectToString = Object.prototype.toString

Batman.extend = (to, objects...) ->
  to[key] = value for key, value of object for object in objects
  to

# `Batman.mixin` applies every key from every argument after the first to the
# first argument. If a mixin has an `initialize` method, it will be called in
# the context of the `to` object, and it's key/values won't be applied.
Batman.mixin = (to, mixins...) ->
  hasSet = typeof to.set is 'function'

  for mixin in mixins
    continue if Batman.typeOf(mixin) isnt 'Object'

    for own key, value of mixin
      continue if key in  ['initialize', 'uninitialize', 'prototype']
      if hasSet
        to.set(key, value)
      else if to.nodeName?
        Batman.data to, key, value
      else
        to[key] = value

    if typeof mixin.initialize is 'function'
      mixin.initialize.call to

  to

# `Batman.unmixin` removes every key/value from every argument after the first
# from the first argument. If a mixin has a `deinitialize` method, it will be
# called in the context of the `from` object and won't be removed.
Batman.unmixin = (from, mixins...) ->
  for mixin in mixins
    for key of mixin
      continue if key in ['initialize', 'uninitialize']

      delete from[key]

    if typeof mixin.uninitialize is 'function'
      mixin.uninitialize.call from

  from

# `Batman.functionName` returns the name of a given function, if any
# Used to deal with functions not having the `name` property in IE
Batman._functionName = Batman.functionName = (f) ->
  return f.__name__ if f.__name__
  return f.name if f.name
  f.toString().match(/\W*function\s+([\w\$]+)\(/)?[1]


Batman._isChildOf = Batman.isChildOf = (parentNode, childNode) ->
  node = childNode.parentNode
  while node
    return true if node == parentNode
    node = node.parentNode
  false

_implementImmediates = (container) ->
  canUsePostMessage = ->
    return false unless container.postMessage
    async = true
    oldMessage = container.onmessage
    container.onmessage = -> async = false
    container.postMessage("","*")
    container.onmessage = oldMessage
    async

  tasks = new Batman.SimpleHash
  count = 0
  getHandle = -> "go#{++count}"

  if container.setImmediate and container.clearImmediate
    Batman.setImmediate = container.setImmediate
    Batman.clearImmediate = container.clearImmediate
  else if canUsePostMessage()
    prefix = 'com.batman.'
    functions = new Batman.SimpleHash
    handler = (e) ->
      return unless ~e.data.search(prefix)
      handle = e.data.substring(prefix.length)
      tasks.unset(handle)?()

    if container.addEventListener
      container.addEventListener('message', handler, false)
    else
      container.attachEvent('onmessage', handler)

    Batman.setImmediate = (f) ->
      tasks.set(handle = getHandle(), f)
      container.postMessage(prefix+handle, "*")
      handle
    Batman.clearImmediate = (handle) -> tasks.unset(handle)
  else if typeof document isnt 'undefined' && "onreadystatechange" in document.createElement("script")
    Batman.setImmediate = (f) ->
      handle = getHandle()
      script = document.createElement("script")
      script.onreadystatechange = ->
        tasks.get(handle)?()
        script.onreadystatechange = null
        script.parentNode.removeChild(script)
        script = null
      document.documentElement.appendChild(script)
      handle
    Batman.clearImmediate = (handle) -> tasks.unset(handle)
  else if process?.nextTick
    functions = {}
    Batman.setImmediate = (f) ->
      handle = getHandle()
      functions[handle] = f
      process.nextTick ->
        functions[handle]?()
        delete functions[handle]
      handle

    Batman.clearImmediate = (handle) ->
      delete functions[handle]

  else
    Batman.setImmediate = (f) -> setTimeout(f, 0)
    Batman.clearImmediate = (handle) -> clearTimeout(handle)

Batman.setImmediate = ->
  _implementImmediates(Batman.container)
  Batman.setImmediate.apply(@, arguments)

Batman.clearImmediate = ->
  _implementImmediates(Batman.container)
  Batman.clearImmediate.apply(@, arguments)

Batman.forEach = (container, iterator, ctx) ->
  if container.forEach
    container.forEach(iterator, ctx)
  else if container.indexOf
    iterator.call(ctx, e, i, container) for e,i in container
  else
    iterator.call(ctx, k, v, container) for k,v of container

Batman.objectHasKey = (object, key) ->
  if typeof object.hasKey is 'function'
    object.hasKey(key)
  else
    key of object

Batman.contains = (container, item) ->
  if container.indexOf
    item in container
  else if typeof container.has is 'function'
    container.has(item)
  else
    Batman.objectHasKey(container, item)

Batman.get = (base, key) ->
  if typeof base.get is 'function'
    base.get(key)
  else
    Batman.Property.forBaseAndKey(base, key).getValue()

Batman.getPath = (base, segments) ->
  for segment in segments
    if base?
      base = Batman.get(base, segment)
      return base unless base?
    else
      return undefined
  base

_entityMap =
  "&": "&amp;"
  "<": "&lt;"
  ">": "&gt;"
  "\"": "&#34;"
  "'": "&#39;"

_unsafeChars = []
_encodedChars = []

for chr of _entityMap
  _unsafeChars.push(chr)
  _encodedChars.push(_entityMap[chr])

_unsafeCharsPattern = new RegExp("[#{_unsafeChars.join('')}]", "g")
_encodedCharsPattern = new RegExp("(#{_encodedChars.join('|')})", "g")

Batman.escapeHTML = do ->
  return (s) -> (""+s).replace(_unsafeCharsPattern, (c) -> _entityMap[c])

Batman.unescapeHTML = do ->
  return (s) ->
    node = document.createElement('DIV')
    node.innerHTML = s
    if node.innerText? then node.innerText else node.textContent

# `translate` is hook for the i18n extra to override and implemnent. All strings which might
# be shown to the user pass through this method. `translate` is aliased to `t` internally.
Batman.translate = (x, values = {}) -> Batman.helpers.interpolate(Batman.get(Batman.translate.messages, x), values)
Batman.translate.messages = {}
Batman.t = -> Batman.translate(arguments...)

Batman.redirect = (url) ->
  Batman.navigator?.redirect url

# `Batman.initializeObject` is called by all the methods in Batman.Object to ensure that the
# object's `_batman` property is initialized and it's own. Classes extending Batman.Object inherit
# methods like `get`, `set`, and `observe` by default on the class and prototype levels, such that
# both instances and the class respond to them and can be bound to. However, CoffeeScript's static
# class inheritance copies over all class level properties indiscriminately, so a parent class'
# `_batman` object will get copied to its subclasses, transferring all the information stored there and
# allowing subclasses to mutate parent state. This method prevents this undesirable behaviour by tracking
# which object the `_batman_` object was initialized upon, and reinitializing if that has changed since
# initialization.
Batman.initializeObject = (object) ->
  if object._batman?
    object._batman.check(object)
  else
    object._batman = new Batman._Batman(object)
