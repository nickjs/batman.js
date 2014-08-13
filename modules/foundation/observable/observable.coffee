Keypath = require './keypath'
SimpleHash = require '../hash/simple_hash'
_Batman = require '../object/_batman'


# Batman.Observable is a generic mixin that can be applied to any object to allow it to be bound to.
# It is applied by default to every instance of `Batman.Object` and subclasses.
module.exports = Observable =
  isObservable: true
  hasProperty: (key) ->
    @_batman?.properties?.hasKey?(key)
  property: (key) ->
    _Batman.initialize(@)
    propertyClass = @propertyClass or Keypath
    properties = @_batman.properties ||= new SimpleHash
    if properties.objectKey( key )
      return properties.getObject(key) or properties.setObject( key, new propertyClass(this, key ) )
    else
      return properties.getString(key) or properties.setString(key, new propertyClass(this, key))
  get: (key) ->
    @property(key).getValue()
  set: (key, val) ->
    @property(key).setValue(val)
  unset: (key) ->
    @property(key).unsetValue()

  getOrSet: SimpleHash::getOrSet

  toggle: (key) ->  @set(key, !@get(key))

  increment: (key, change=1) ->
    value = @get(key) || 0
    @set(key, value + change)
  decrement: (key, change=1) ->
    value = @get(key) || 0
    @set(key, value - change)

  # `forget` removes an observer from an object. If the callback is passed in,
  # its removed. If no callback but a key is passed in, all the observers on
  # that key are removed. If no key is passed in, all observers are removed.
  forget: (key, observer) ->
    if key
      @property(key).forget(observer)
    else
      @_batman.properties?.forEach (key, property) -> property.forget()
    @

  # `observe` takes a key and a callback. Whenever the value for that key changes, your
  # callback will be called in the context of the original object.
  observe: (key, args...) ->
    @property(key).observe(args...)
    @

  observeAndFire: (key, args...) ->
    @property(key).observeAndFire(args...)
    @

  observeOnce: (key, args...) ->
    @property(key).observeOnce(args...)
    @
