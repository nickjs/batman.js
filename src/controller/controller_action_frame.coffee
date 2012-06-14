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
    @remainingActions++

  actionFinish: ->
    @remainingActions--
    if @remainingActions == 0
      @fire 'complete'

  immediateActionTaken: (options) ->
    @actionStart(options)
    @actionFinish(options)
