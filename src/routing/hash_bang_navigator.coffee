#= require ./navigator

class Batman.HashbangNavigator extends Batman.Navigator
  HASH_PREFIX: '#!'
  if window? and 'onhashchange' of window
    @::startWatching = ->
      Batman.DOM.addEventListener window, 'hashchange', @handleCurrentLocation
    @::stopWatching = ->
      Batman.DOM.removeEventListener window, 'hashchange', @handleCurrentLocation
  else
    @::startWatching = ->
      @interval = setInterval @handleCurrentLocation, 100
    @::stopWatching = ->
      @interval = clearInterval @interval
  pushState: (stateObject, title, path) ->
    window.location.hash = @linkTo(path)
  replaceState: (stateObject, title, path) ->
    loc = window.location
    loc.replace("#{loc.pathname}#{loc.search}#{@linkTo(path)}")
  linkTo: (url) -> @HASH_PREFIX + url
  pathFromLocation: (location) ->
    hash = location.hash
    if hash?.substr(0,2) is @HASH_PREFIX
      @normalizePath(hash.substr(2))
    else
      '/'
  handleLocation: (location) ->
    return super unless Batman.config.usePushState
    realPath = Batman.PushStateNavigator::pathFromLocation(location)
    if realPath is '/'
      super
    else
      location.replace(@normalizePath("#{Batman.config.pathToApp}#{@linkTo(realPath)}"))
