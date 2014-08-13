Navigator = require "./navigator"

module.exports = class HashbangNavigator extends Navigator
  hashPrefix: '#!'

  if window? and 'onhashchange' of window
    @::startWatching = ->
      Batman.DOM.addEventListener window, 'hashchange', @handleHashChange
    @::stopWatching = ->
      Batman.DOM.removeEventListener window, 'hashchange', @handleHashChange
  else
    @::startWatching = ->
      @interval = setInterval @detectHashChange, 100
    @::stopWatching = ->
      @interval = clearInterval @interval

  handleHashChange: =>
    return @ignoreHashChange = false if @ignoreHashChange
    @handleCurrentLocation()

  detectHashChange: =>
    return if @previousHash == window.location.hash
    @previousHash = window.location.hash
    @handleHashChange()

  pushState: (stateObject, title, path) ->
    link = @linkTo(path)
    return if link == window.location.hash

    @ignoreHashChange = true
    window.location.hash = link

  replaceState: (stateObject, title, path, loc=window.location) ->
    link = @linkTo(path)
    return if link == loc.hash

    @ignoreHashChange = true
    loc.replace("#{loc.pathname || ''}#{loc.search || ''}#{link || ''}")

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

    pushStatePath = Batman.PushStateNavigator::pathFromLocation(location)

    # if someone pastes a pushState URL but we're using hashbangs, we need to switch to that instead
    if pushStatePath isnt '/'
      location.replace(@normalizePath("#{Batman.config.pathToApp}#{@linkTo(pushStatePath)}#{if @initialHash then '##BATMAN##' + @initialHash else ''}"))
    #otherwise, just handle the hashbang URL
    else
      super
