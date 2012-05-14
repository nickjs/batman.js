#= require ./property

class Batman.Keypath extends Batman.Property
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
    base = Batman.getPath(@base, @segments.slice(0, -1))
    return unless base?
    Batman.Keypath.forBaseAndKey(base, @segments[@depth-1])
  valueFromAccessor: ->
    if @depth is 1 then super else Batman.getPath(@base, @segments)
  setValue: (val) -> if @depth is 1 then super else @terminalProperty()?.setValue(val)
  unsetValue: -> if @depth is 1 then super else @terminalProperty()?.unsetValue()
