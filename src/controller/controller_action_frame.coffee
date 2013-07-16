class Batman.ControllerActionFrame extends Batman.Object
  operationOccurred: false
  remainingOperations: 0

  @::event('complete').oneShot = true

  constructor: (options, onComplete) ->
    super(options)
    @once('complete', onComplete)

  startOperation: (options = {}) ->
    @operationOccurred = true if !options.internal
    @_changeOperationsCounter(1)
    true

  finishOperation: ->
    @_changeOperationsCounter(-1)
    true

  startAndFinishOperation: (options) ->
    @startOperation(options)
    @finishOperation(options)
    true

  _changeOperationsCounter: (delta) ->
    @remainingOperations += delta
    if @remainingOperations == 0
      @fire('complete')

    @parentFrame?._changeOperationsCounter(delta)
    return
