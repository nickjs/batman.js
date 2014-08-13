{extend} = require '../object_helpers'
# _Batman provides a convenient, parent class and prototype aware place to store hidden
# object state. Things like observers, accessors, and states belong in the `_batman` object
# attached to every Batman.Object subclass and subclass instance.

module.exports = class _Batman
  @initialize: (object) ->
    if object._batman?
      object._batman.check(object)
    else
      object._batman = new _Batman(object)

  constructor: (@object) ->

  # Ensures that this `_batman` was created referencing
  # the object it is pointing to.
  check: (object) ->
    if object != @object
      object._batman = new _Batman(object)
      return false
    return true

  # `get` is a prototype and class aware property access method. `get` will traverse the prototype chain, asking
  # for the passed key at each step, and then attempting to merge the results into one object.
  # It can only do this if at each level an `Array`, `Hash`, or `Set` is found, so try to use
  # those if you need `_batman` inheritance.
  get: (key) ->
    # Get all the keys from the ancestor chain
    results = @getAll(key)
    switch results.length
      when 0
        undefined
      when 1
        results[0]
      else
        # And then try to merge them if there is more than one. Use `concat` on arrays, and `merge` on
        # sets and hashes.
        reduction = if results[0].concat?
          (a, b) -> a.concat(b)
        else if results[0].merge?
          (a, b) -> a.merge(b)
        else if results.every((x) -> typeof x is 'object')
          results.unshift({})
          (a, b) -> extend(a, b)

        if reduction
          results.reduceRight(reduction)
        else
          results

  # `getFirst` is a prototype and class aware property access method. `getFirst` traverses the prototype chain,
  # and returns the value of the first `_batman` object which defines the passed key. Useful for
  # times when the merged value doesn't make sense or the value is a primitive.
  getFirst: (key) ->
    results = @getAll(key)
    results[0]

  # `getAll` is a prototype and class chain iterator. When passed a key or function, it applies it to each
  # parent class or parent prototype, and returns the undefined values, closest ancestor first.
  getAll: (keyOrGetter) ->
    # Get a function which pulls out the key from the ancestor's `_batman` or use the passed function.
    if typeof keyOrGetter is 'function'
      getter = keyOrGetter
    else
      getter = (ancestor) -> ancestor._batman?[keyOrGetter]

    # Apply it to all the ancestors, and then this `_batman`'s object.
    results = @ancestors(getter)
    if val = getter(@object)
      results.unshift val
    results

  # `ancestors` traverses the prototype or class chain and returns the application of a function to each
  # object in the chain. `ancestors` does this _only_ to the `@object`'s ancestors, and not the `@object`
  # itself.
  ancestors: (getter) ->
    @_allAncestors ||= @allAncestors()

    if getter
      results = []
      for ancestor in @_allAncestors
        val = getter(ancestor)
        results.push(val) if val?
      results
    else
      @_allAncestors

  allAncestors: ->
    results = []
    # Decide if the object is a class or not, and pull out the first ancestor
    isClass = !!@object.prototype

    parent = if isClass
      @object.__super__?.constructor
    else
      if (proto = Object.getPrototypeOf(@object)) == @object
        @object.constructor.__super__
      else
        proto

    if parent?
      parent._batman?.check(parent)
      results.push(parent)

      if parent._batman?
        results = results.concat(parent._batman.allAncestors())

    results

  set: (key, value) ->
    @[key] = value
