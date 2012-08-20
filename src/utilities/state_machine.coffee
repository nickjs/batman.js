#= require ../object

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
      key = "is#{Batman.helpers.capitalize(state)}"
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

  onTransition: (from, into, callback) -> @on("#{from}->#{into}", callback)
  onEnter: (into, callback) -> @on("enter #{into}", callback)
  onExit: (from, callback) -> @on("exit #{from}", callback)

  startTransition: Batman.Property.wrapTrackingPrevention (event) ->
    if @isTransitioning
      @nextEvents.push event
      return

    previousState = @get('state')
    nextState = @nextStateForEvent(event)

    if !nextState
      return false

    @isTransitioning = true
    @fire "exit #{previousState}"
    @set('_state', nextState)
    @fire "#{previousState}->#{nextState}"
    @fire "enter #{nextState}"
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
