#= require_tree ../hash

class Batman.Params extends Batman.Hash
  constructor: (@hash, @navigator) ->
    super(@hash)

    @url = new Batman.UrlParams({}, @navigator, this)

  @accessor 'url', -> @url

class Batman.UrlParams extends Batman.Hash
  constructor: (@hash, @navigator, @params) ->
    super(@hash)

    @replace(@paramsFromUri())
    @updateParams()

    @on 'change', (obj) =>
      obj.updateUrl()
      obj.updateParams()

  paramsFromUri: ->
    @currentUri().queryParams

  currentPath: ->
    @params.get('path')

  currentUri: ->
    new Batman.URI(@currentPath())

  pathFromRoutes: ->
    route = @navigator.app.get('currentRoute')
    params =
      controller: route.controller
      action: route.action

    Batman.mixin(params, @toObject())

    @navigator.app.get('dispatcher').pathFromParams(params)

  pathFromParams: ->
    if path = @pathFromRoutes()
      return path

    uri = @currentUri()
    uri.queryParams = @toObject()
    uri.toString()

  updateUrl: ->
    @navigator.pushState(null, '', @pathFromParams())

  updateParams: ->
    @params.update(@toObject())
