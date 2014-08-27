BatmanObject = require './object'
Property = require '../observable/property'

module.exports = class Proxy extends BatmanObject
  isProxy: true

  constructor: (target) ->
    super()
    @set 'target', target if target?

  @accessor 'target', Property.defaultAccessor

  @accessor
    get: (key) -> @get('target')?.get(key)
    set: (key, value) -> @get('target')?.set(key, value)
    unset: (key) -> @get('target')?.unset(key)

  @delegatesToTarget: (functionNames...) ->
    functionNames.forEach (functionName) =>
      @::[functionName] = -> @get('target')?[functionName](arguments...)