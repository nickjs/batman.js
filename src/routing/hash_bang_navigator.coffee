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
    link = @linkTo(path)
    return if link == window.location.hash

    @ignoreHashChange = true
    window.location.hash = link

  replaceState: (stateObject, title, path) ->
    link = @linkTo(path)
    return if link == loc.hash

    @ignoreHashChange = true
    loc.replace("#{loc.pathname}#{loc.search}#{link}")

  linkTo: (url) ->
    @hashPrefix + url

  pathFromLocation: (location) ->
    hash = location.hash
    length = @hashPrefix.length

    if hash?.substr(0, length) is @hashPrefix
      @normalizePath(hash.substr(length))
    else
      '/'

  handleLocation: (location) ->
    # if the app doesn't support pushState at all, URL's will never be pushState URL's, so we can return
    return super if not Batman.config.usePushState

    # if someone pastes a pushState URL but we're using hashbangs, we need to switch to that instead
    if (pushStatePath = Batman.PushStateNavigator::pathFromLocation(location)) isnt '/'
      location.replace(@normalizePath("#{Batman.config.pathToApp}#{@linkTo(pushStatePath)}"))
    #otherwise, just handle the hashbang URL
    else
      super
