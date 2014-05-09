#= require ../hash/hash

class Batman.Params extends Batman.Hash
  constructor: (@hash, @navigator) ->
    super(@hash)

    @url = new Batman.UrlParams({}, @navigator, this)

  @accessor 'url', -> @url

class Batman.UrlParams extends Batman.Hash
  constructor: (@hash, @navigator, @params) ->
    super(@hash)

    @replace(@_paramsFromUri())
    @updateParams()

    @on 'change', (obj) =>
      obj.updateUrl()
      obj.updateParams()

  updateUrl: ->
    @navigator.pushState(null, '', @_pathFromParams())

  updateParams: ->
    @params.update(@toObject())

  _paramsFromUri: ->
    @_currentUri().queryParams

  _currentPath: ->
    @params.get('path')

  _currentUri: ->
    new Batman.URI(@_currentPath())

  _pathFromRoutes: ->
    route = @navigator.app.get('currentRoute')
    params =
      controller: route.controller
      action: route.action

    Batman.mixin(params, @toObject())

    @navigator.app.get('dispatcher').pathFromParams(params)

  _pathFromParams: ->
    if path = @_pathFromRoutes()
      return path

    uri = @_currentUri()
    uri.queryParams = @toObject()
    uri.toString()
