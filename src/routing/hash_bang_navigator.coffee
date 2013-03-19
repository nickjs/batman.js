#= require ./navigator

class Batman.HashbangNavigator extends Batman.Navigator
  hashPrefix: '#!'

  if window? and 'onhashchange' of window
    @::startWatching = ->
      Batman.DOM.addEventListener window, 'hashchange', @handleHashChange
    @::stopWatching = ->
      Batman.DOM.removeEventListener window, 'hashchange', @handleHashChange
  else
    @::startWatching = ->
      @interval = setInterval @handleCurrentLocation, 100
    @::stopWatching = ->
      @interval = clearInterval @interval

  handleHashChange: =>
    return @ignoreHashChange = false if @ignoreHashChange
    @handleCurrentLocation()

  pushState: (stateObject, title, path) ->
    @ignoreHashChange = true
    window.location.hash = @linkTo(path)

  replaceState: (stateObject, title, path) ->
    @ignoreHashChange = true
    loc = window.location
    loc.replace("#{loc.pathname}#{loc.search}#{@linkTo(path)}")

  linkTo: (url) -> @hashPrefix + url

  pathFromLocation: (location) ->
    hash = location.hash
    length = @hashPrefix.length

    if hash?.substr(0, length) is @hashPrefix
      @normalizePath(hash.substr(length))
    else
      '/'

  handleLocation: (location) ->
    return super unless Batman.config.usePushState
    realPath = Batman.PushStateNavigator::pathFromLocation(location)
    if realPath is '/'
      super
    else
      location.replace(@normalizePath("#{Batman.config.pathToApp}#{@linkTo(realPath)}"))
