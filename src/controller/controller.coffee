#= require ./render_cache

class Batman.Controller extends Batman.Object
  @singleton 'sharedController'

  @wrapAccessor 'routingKey', (core) ->
    get: ->
      if @routingKey?
        @routingKey
      else
        Batman.developer.error("Please define `routingKey` on the prototype of #{Batman.functionName(@constructor)} in order for your controller to be minification safe.") if Batman.config.minificationErrors
        Batman.functionName(@constructor).replace(/Controller$/, '')

  @accessor '_renderContext', -> Batman.RenderContext.root().descend(@)

  _optionsFromFilterArguments = (options, nameOrFunction) ->
    if not nameOrFunction
      nameOrFunction = options
      options = {}
    else
      if typeof options is 'string'
        options = {only: [options]}
      else
        options.only = [options.only] if options.only and Batman.typeOf(options.only) isnt 'Array'
        options.except = [options.except] if options.except and Batman.typeOf(options.except) isnt 'Array'
    options.block = nameOrFunction
    options

  @beforeFilter: ->
    Batman.initializeObject @
    options = _optionsFromFilterArguments(arguments...)
    filters = @_batman.beforeFilters ||= new Batman.SimpleHash
    filters.set(options.block, options)

  @afterFilter: ->
    Batman.initializeObject @
    options = _optionsFromFilterArguments(arguments...)
    filters = @_batman.afterFilters ||= new Batman.SimpleHash
    filters.set(options.block, options)

  @afterFilter (params) ->
    if @autoScrollToHash && params['#']?
      @scrollToHash(params['#'])

  constructor: ->
    @_actionFrames = []
    super

  renderCache: new Batman.RenderCache
  defaultRenderYield: 'main'
  autoScrollToHash: true

  # You shouldn't call this method directly. It will be called by the dispatcher when a route is called.
  # If you need to call a route manually, use `Batman.redirect()`.
  dispatch: (action, params = {}) ->
    params.controller ||= @get 'routingKey'
    params.action ||= action
    params.target ||= @

    @_actionFrames = []
    @set 'action', action
    @set 'params', params

    Batman.DOM.Yield.cycleAll()

    @executeAction(action, params)

    Batman.DOM.Yield.clearAllStale()

    redirectTo = @_afterFilterRedirect
    delete @_afterFilterRedirect

    Batman.redirect(redirectTo) if redirectTo

  executeAction: (action, params = @get('params')) ->
    Batman.developer.assert @[action], "Error! Controller action #{@get 'routingKey'}.#{action} couldn't be found!"

    frame = new Batman.ControllerActionFrame {actionTaken: false, action: action}, =>
      @_runFilters action, params, 'afterFilters'
      Batman.navigator?.redirect = oldRedirect

    @_actionFrames.push frame
    frame.actionStart({internal: true})

    oldRedirect = Batman.navigator?.redirect
    Batman.navigator?.redirect = @redirect
    @_runFilters action, params, 'beforeFilters'

    result = @[action](params)

    @render() if not frame.actionTaken
    frame.actionFinish()

    result

  redirect: (url) =>
    frame = @_actionFrames[@_actionFrames.length - 1]

    if frame
      if frame.actionTaken
        Batman.developer.warn "Warning! Trying to redirect but an action has already be taken during #{@get('routingKey')}.#{frame.action || @get('action')}}"

      frame.immediateActionTaken()

      if @_afterFilterRedirect
        Batman.developer.warn "Warning! Multiple actions trying to redirect!"
      else
        @_afterFilterRedirect = url
    else
      if Batman.typeOf(url) is 'Object'
        url.controller = @ if not url.controller

      Batman.redirect url

  render: (options = {}) ->
    if frame = @_actionFrames?[@_actionFrames.length - 1]
      frame.actionStart()

    # Ensure the frame is marked as having had an action executed so that render false prevents the implicit render.
    if options is false
      frame.actionFinish()
      return

    action = frame?.action || @get('action')

    if options
      options.into ||= @defaultRenderYield

    if not options.view
      options.viewClass ||= Batman.currentApp?[Batman.helpers.camelize("#{@get('routingKey')}_#{action}_view")] || Batman.View
      options.context ||= @get('_renderContext')
      options.source ||= Batman.helpers.underscore(@get('routingKey') + '/' + action)
      view = @renderCache.viewForOptions(options)
    else
      view = options.view
      options.view = null

    if view
      Batman.currentApp?.prevent 'ready'
      view.on 'ready', =>
        Batman.DOM.Yield.withName(options.into).replace view.get('node')
        Batman.currentApp?.allowAndFire 'ready'
        frame?.actionFinish()
    view

  scrollToHash: (hash = @get('params')['#'])-> Batman.DOM.scrollIntoView(hash)

  _runFilters: (action, params, filters) ->
    if filters = @constructor._batman?.get(filters)
      filters.forEach (_, options) =>
        return if options.only and action not in options.only
        return if options.except and action in options.except

        block = options.block
        if typeof block is 'function' then block.call(@, params) else @[block]?(params)
