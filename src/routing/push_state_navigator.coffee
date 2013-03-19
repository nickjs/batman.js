#= require ./navigator

class Batman.PushStateNavigator extends Batman.Navigator
  @isSupported: -> window?.history?.pushState?
  startWatching: ->
    Batman.DOM.addEventListener window, 'popstate', @handleCurrentLocation
  stopWatching: ->
    Batman.DOM.removeEventListener window, 'popstate', @handleCurrentLocation
  pushState: (stateObject, title, path) ->
    if path != @pathFromLocation(window.location)
      window.history.pushState(stateObject, title, @linkTo(path))
  replaceState: (stateObject, title, path) ->
    if path != @pathFromLocation(window.location)
      window.history.replaceState(stateObject, title, @linkTo(path))
  linkTo: (url) ->
    @normalizePath(Batman.config.pathToApp, url)
  pathFromLocation: (location) ->
    fullPath = "#{location.pathname or ''}#{location.search or ''}"
    prefixPattern = new RegExp("^#{@normalizePath(Batman.config.pathToApp)}")
    @normalizePath(fullPath.replace(prefixPattern, ''))
  handleLocation: (location) ->
    path = @pathFromLocation(location)
    if path is '/' and (hashbangPath = Batman.HashbangNavigator::pathFromLocation(location)) isnt '/'
      @redirect(hashbangPath, true)
    else
      super
