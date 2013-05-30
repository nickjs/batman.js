#= require ../object
#= require ./simple_set
#= require ../enumerable

class Batman.Set extends Batman.Object
  constructor: -> Batman.SimpleSet.apply @, arguments

  Batman.extend @prototype, Batman.Enumerable

  @_applySetAccessors = (klass) ->
    accessors =
      first:   -> @toArray()[0]
      last:    -> @toArray()[@length - 1]
      isEmpty: -> @isEmpty()
      toArray: -> @toArray()
      length:  -> @registerAsMutableSource(); @length
      indexedBy:          -> new Batman.TerminalAccessible (key) => @indexedBy(key)
      indexedByUnique:    -> new Batman.TerminalAccessible (key) => @indexedByUnique(key)
      sortedBy:           -> new Batman.TerminalAccessible (key) => @sortedBy(key)
      sortedByDescending: -> new Batman.TerminalAccessible (key) => @sortedBy(key, 'desc')
    klass.accessor(key, accessor) for key, accessor of accessors
    return

  @_applySetAccessors(@)

  for k in ['add', '_add', 'remove', '_remove', 'addAndRemove', 'clear', 'replace', 'indexedBy', 'indexedByUnique', 'sortedBy', 'equality', '_indexOfItem']
    @::[k] = Batman.SimpleSet::[k]

  for k in ['find', 'merge', 'forEach', 'toArray', 'isEmpty', 'has']
    do (k) =>
      @::[k] = ->
        @registerAsMutableSource()
        Batman.SimpleSet::[k].apply(@, arguments)

  toJSON: @::toArray

