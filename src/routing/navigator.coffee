class Batman.Navigator
  @forApp: (app) -> new (@defaultClass())(app)
  @defaultClass: ->
    if Batman.config.usePushState and Batman.PushStateNavigator.isSupported()
      Batman.PushStateNavigator
    else
      Batman.HashbangNavigator

  constructor: (@app) ->

  start: ->
    return if typeof window is 'undefined'
    return if @started
    @started = yes
    @startWatching()
    Batman.currentApp.prevent 'ready'
    Batman.setImmediate =>
      if @started && Batman.currentApp
        @handleCurrentLocation()
        Batman.currentApp.allowAndFire 'ready'

  stop: ->
    @stopWatching()
    @started = no

  handleCurrentLocation: => @handleLocation(window.location)
  handleLocation: (location) ->
    path = @pathFromLocation(location)
    return if path is @cachedPath
    @dispatch(path)

  dispatch: (params) ->
    @cachedPath = @app.get('dispatcher').dispatch(params)
    @cachedPath = @_lastRedirect if @_lastRedirect
    @cachedPath

  redirect: (params, replaceState=false) ->
    pathFromParams = @app.get('dispatcher').pathFromParams?(params)
    @_lastRedirect = pathFromParams if pathFromParams

    path = @dispatch(params)

    if !@_lastRedirect or @_lastRedirect is path
      @[if replaceState then 'replaceState' else 'pushState'](null, '', path)

    path

  push: (params) ->
    Batman.developer.deprecated("Navigator::push", "Please use Batman.redirect({}) instead.")
    @redirect(params)
  replace: (params) ->
    Batman.developer.deprecated("Navigator::replace", "Please use Batman.redirect({}, true) instead.")
    @redirect(params, true)

  normalizePath: (segments...) ->
    segments = for seg, i in segments
      "#{seg}".replace(/^(?!\/)/, '/').replace(/\/+$/,'')
    segments.join('') or '/'

  @normalizePath: @::normalizePath
