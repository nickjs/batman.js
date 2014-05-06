#= require_tree ../hash

class Batman.Params extends Batman.Hash
  constructor: (@hash, @navigator) ->
    super

    @url = new Batman.UrlParams({}, @navigator, this)

  @accessor 'url', -> @url

class Batman.UrlParams extends Batman.Hash
  constructor: (@hash, @navigator, @params) ->
    super

    @replace(@paramsFromUri())

    @on 'change', (obj) =>
      obj.updateUrl()
      obj.updateParams()

  paramsFromUri: ->
    @currentUri().queryParams

  currentPath: ->
    window.location.pathname + window.location.search

  currentUri: ->
    new Batman.URI(@currentPath())

  updateUrl: ->
    uri = @currentUri()
    uri.queryParams = @toJSON()
    path = uri.toString()

    @navigator.setPath(path)

  updateParams: ->
    @params.update(@toJSON())
