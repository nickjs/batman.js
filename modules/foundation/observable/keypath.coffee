{getPath} = require '../object_helpers'
Property = require './property'

module.exports = class Keypath extends Property
  constructor: (base, key) ->
    if typeof key is 'string'
      @segments = key.split('.')
      @depth = @segments.length
    else
      @segments = [key]
      @depth = 1
    super
  isCachable: ->
    if @depth is 1 then super else true
  terminalProperty: ->
    base = getPath(@base, @segments.slice(0, -1))
    return unless base?
    Keypath.forBaseAndKey(base, @segments[@depth-1])
  valueFromAccessor: ->
    if @depth is 1 then super else getPath(@base, @segments)
  setValue: (val) -> if @depth is 1 then super else @terminalProperty()?.setValue(val)
  unsetValue: -> if @depth is 1 then super else @terminalProperty()?.unsetValue()
