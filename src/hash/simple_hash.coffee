class Batman.SimpleHash
  constructor: (obj) ->
    @_storage = {}
    @length = 0
    @update(obj) if obj?
  Batman.extend @prototype, Batman.Enumerable
  propertyClass: Batman.Property
  hasKey: (key) ->
    if @objectKey(key)
      return false unless @_objectStorage
      if pairs = @_objectStorage[@hashKeyFor(key)]
        for pair in pairs
          return true if @equality(pair[0], key)
      return false
    else
      key = @prefixedKey(key)
      @_storage.hasOwnProperty(key)
  get: (key) ->
    if @objectKey(key)
      return undefined unless @_objectStorage
      if pairs = @_objectStorage[@hashKeyFor(key)]
        for pair in pairs
          return pair[1] if @equality(pair[0], key)
    else
      @_storage[@prefixedKey(key)]
  set: (key, val) ->
    if @objectKey(key)
      @_objectStorage ||= {}
      pairs = @_objectStorage[@hashKeyFor(key)] ||= []
      for pair in pairs
        if @equality(pair[0], key)
          return pair[1] = val
      @length++
      pairs.push([key, val])
      val
    else
      key = @prefixedKey(key)
      @length++ unless @_storage[key]?
      @_storage[key] = val
  unset: (key) ->
    if @objectKey(key)
      return undefined unless @_objectStorage
      hashKey = @hashKeyFor(key)
      if pairs = @_objectStorage[hashKey]
        for [obj,value], index in pairs
          if @equality(obj, key)
            pair = pairs.splice(index,1)
            delete @_objectStorage[hashKey] unless pairs.length
            @length--
            return pair[0][1]
    else
      key = @prefixedKey(key)
      val = @_storage[key]
      if @_storage[key]?
        @length--
        delete @_storage[key]
      val
  getOrSet: (key, valueFunction) ->
    currentValue = @get(key)
    unless currentValue
      currentValue = valueFunction()
      @set(key, currentValue)
    currentValue
  prefixedKey: (key) -> "_"+key
  unprefixedKey: (key) -> key.slice(1)
  hashKeyFor: (obj) -> obj?.hashKey?() or obj
  equality: (lhs, rhs) ->
    return true if lhs is rhs
    return true if lhs isnt lhs and rhs isnt rhs # when both are NaN
    return true if lhs?.isEqual?(rhs) and rhs?.isEqual?(lhs)
    return false
  objectKey: (key) -> typeof key isnt 'string'
  forEach: (iterator, ctx) ->
    results = []
    if @_objectStorage
      for key, values of @_objectStorage
        for [obj, value] in values.slice()
          results.push iterator.call(ctx, obj, value, this)
    for key, value of @_storage
      results.push iterator.call(ctx, @unprefixedKey(key), value, this)
    results
  keys: ->
    result = []
    # Explicitly reference this foreach so that if it's overriden in subclasses the new implementation isn't used.
    Batman.SimpleHash::forEach.call @, (key) -> result.push key
    result
  clear: ->
    @_storage = {}
    delete @_objectStorage
    @length = 0
  isEmpty: ->
    @length is 0
  merge: (others...) ->
    merged = new @constructor
    others.unshift(@)
    for hash in others
      hash.forEach (obj, value) ->
        merged.set obj, value
    merged
  update: (object) -> @set(k,v) for k,v of object
  replace: (object) ->
    @forEach (key, value) =>
      @unset(key) unless key of object
    @update(object)
  toObject: ->
    obj = {}
    for key, value of @_storage
      obj[@unprefixedKey(key)] = value
    if @_objectStorage
      for key, pair of @_objectStorage
        obj[key] = pair[0][1] # the first value for this key
    obj
  toJSON: @::toObject
