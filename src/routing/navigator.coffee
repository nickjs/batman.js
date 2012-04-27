class Batman.Navigator
  @defaultClass: ->
    if Batman.config.usePushState and Batman.PushStateNavigator.isSupported()
      Batman.PushStateNavigator
    else
      Batman.HashbangNavigator
  @forApp: (app) -> new (@defaultClass())(app)
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
  handleLocation: (location) ->
    path = @pathFromLocation(location)
    return if path is @cachedPath
    @dispatch(path)
  handleCurrentLocation: => @handleLocation(window.location)
  dispatch: (params) ->
    @cachedPath = @app.get('dispatcher').dispatch(params)
  push: (params) ->
    path = @dispatch(params)
    @pushState(null, '', path)
    path
  replace: (params) ->
    path = @dispatch(params)
    @replaceState(null, '', path)
    path
  redirect: @::push
  normalizePath: (segments...) ->
    segments = for seg, i in segments
      "#{seg}".replace(/^(?!\/)/, '/').replace(/\/+$/,'')
    segments.join('') or '/'
  @normalizePath: @::normalizePath
