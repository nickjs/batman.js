class Batman.ControllerActionFrame extends Batman.Object
  actionTaken: false
  remainingActions: 0
  @::event('complete').oneShot = true

  constructor: (options, onComplete) ->
    super(options)
    @on 'complete', onComplete

  actionStart: (options = {}) ->
    if !options.internal
      @actionTaken = true
    @_changeActionsCounter(1)
    true

  actionFinish: ->
    @_changeActionsCounter(-1)
    true

  immediateActionTaken: (options) ->
    @actionStart(options)
    @actionFinish(options)
    true

  _changeActionsCounter: (delta) ->
    @remainingActions += delta
    if @remainingActions == 0
      @fire 'complete'
    @parentFrame?._changeActionsCounter(delta)
    return
