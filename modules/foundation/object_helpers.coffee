
_objectToString = Object::toString

ObjectHelpers =
  hashKeyFor: (obj) ->
    if hashKey = obj?.hashKey?()
      hashKey
    else
      typeString = _objectToString.call(obj)
      if typeString is "[object Array]" then typeString else obj

  get: (base, key) ->
    if typeof base.get is 'function'
      base.get(key)
    else
      Batman.Keypath.forBaseAndKey(base, key).getValue()


  getPath: (base, segments) ->
    for segment in segments
      if base?
        base = ObjectHelpers.get(base, segment)
        return base unless base?
      else
        return
    base

  extend: (to, objects...) ->
    to[key] = value for key, value of object for object in objects
    to

  mixin: (to, mixins...) ->
    hasSet = typeof to.set is 'function'

    for mixin in mixins
      continue if ObjectHelpers.typeOf(mixin) isnt 'Object'

      for own key, value of mixin
        continue if key in  ['initialize', 'uninitialize', 'prototype']
        if hasSet
          to.set(key, value)
        else if to.nodeName?
          Batman.data(to, key, value)
        else
          to[key] = value

      if typeof mixin.initialize is 'function'
        mixin.initialize.call(to)
    to

  unmixin: (from, mixins...) ->
    for mixin in mixins
      for key of mixin
        continue if key in ['initialize', 'uninitialize']

        delete from[key]

      if typeof mixin.uninitialize is 'function'
        mixin.uninitialize.call from

    from

  typeOf: (object) ->
    return "Undefined" if typeof object == 'undefined'
    _objectToString.call(object).slice(8, -1)

  forEach: (container, iterator, ctx) ->
    if container.forEach
      container.forEach(iterator, ctx)
    else if container.indexOf
      iterator.call(ctx, e, i, container) for e,i in container
    else
      iterator.call(ctx, k, v, container) for k,v of container
    return

  objectHasKey: (object, key) ->
    if typeof object.hasKey is 'function'
      object.hasKey(key)
    else
      key of object

  # `Batman.functionName` returns the name of a given function, if any
  # Used to deal with functions not having the `name` property in IE
  functionName: (f) ->
    return f.__name__ if f.__name__
    return f.name if f.name
    f.toString().match(/\W*function\s+([\w\$]+)\(/)?[1]

  contains: (container, item) ->
    if container.indexOf
      item in container
    else if typeof container.has is 'function'
      container.has(item)
    else
      ObjectHelpers.objectHasKey(container, item)

  initializeObject: (obj) ->
    Batman.Object::initializeBatman.call(obj)

  exportHelpers: (onto) ->
    for k in ['mixin', 'extend', 'unmixin', 'redirect', 'typeOf', 'redirect', 'setImmediate', 'clearImmediate']
      onto["$#{k}"] = Batman[k]
    onto

  exportGlobals: -> Batman.exportHelpers(Batman.container)

module.exports = ObjectHelpers