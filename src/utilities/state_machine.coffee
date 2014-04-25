#= require ../object
#= require ../utilities/utilities
#= require ../utilities/string_helpers

class Batman.StateMachine extends Batman.Object
  @InvalidTransitionError: (@message = "") ->
  @InvalidTransitionError.prototype = new Error

  @transitions: (table) ->
    # Allow a shorthand for specifying a whole bunch of `from` states to go to one `to` state
    for k, v of table when (v.from && v.to)
      object = {}
      if v.from.forEach
        v.from.forEach (fromKey) -> object[fromKey] = v.to
      else
        object[v.from] = v.to
      table[k] = object

    @::transitionTable = Batman.extend {}, @::transitionTable, table

    predicateKeys = []
    definePredicate = (state) =>
      key = "is#{Batman.helpers.titleize(state)}"
      return if @::[key]?
      predicateKeys.push key
      @::[key] = -> @get('state') == state

    for k, transitions of @::transitionTable when !@::[k]
      do (k) =>
        @::[k] = -> @startTransition(k)

      for fromState, toState of transitions
        definePredicate(fromState)
        definePredicate(toState)

    if predicateKeys.length
      @accessor predicateKeys..., (key) -> @[key]()
    @

  constructor: (startState) ->
    @nextEvents = []
    @set('_state', startState)

  @accessor 'state', -> @get('_state')
  isTransitioning: false
  transitionTable: {}

  _transitionEvent: (from, into) -> "#{from}->#{into}"
  _enterEvent: (into) -> "enter #{into}"
  _exitEvent: (from) -> "exit #{from}"
  _beforeEvent: (into) -> "before #{into}"

  onTransition: (from, into, callback) -> @on(@_transitionEvent(from, into), callback)
  onEnter: (into, callback) -> @on(@_enterEvent(into), callback)
  onExit: (from, callback) -> @on(@_exitEvent(from), callback)
  onBefore: (into, callback) -> @on(@_beforeEvent(into), callback)

  offTransition: (from, into, callback) -> @off(@_transitionEvent(from, into), callback)
  offEnter: (into, callback) -> @off(@_enterEvent(into), callback)
  offExit: (from, callback) -> @off(@_exitEvent(from), callback)
  offBefore: (into, callback) -> @off(@_beforeEvent(into), callback)

  startTransition: Batman.Property.wrapTrackingPrevention (event) ->
    if @isTransitioning
      @nextEvents.push event
      return

    previousState = @get('state')
    nextState = @nextStateForEvent(event)

    if !nextState
      return false

    @fire @_beforeEvent(nextState)

    @isTransitioning = true
    @fire @_exitEvent(previousState)
    @set('_state', nextState)
    @fire @_transitionEvent(previousState, nextState)
    @fire @_enterEvent(nextState)
    @fire event
    @isTransitioning = false

    if @nextEvents.length > 0
      @startTransition @nextEvents.shift()
    true

  canStartTransition: (event, fromState = @get('state')) -> !!@nextStateForEvent(event, fromState)
  nextStateForEvent: (event, fromState = @get('state')) -> @transitionTable[event]?[fromState]

class Batman.DelegatingStateMachine extends Batman.StateMachine
  constructor: (startState, @base) ->
    super(startState)

  fire: ->
    result = super
    @base.fire(arguments...)
    result
