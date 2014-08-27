{Hash} = require 'foundation'

module.exports = class UrlParams extends Hash
  constructor: (@hash, @navigator, @params) ->
    super(@hash)

    @replace(@_paramsFromUri())
    @_updateParams()

    @on 'change', (obj) ->
      obj._updateUrl()
      obj._updateParams()

  _updateUrl: ->
    @navigator.pushState(null, '', @_pathFromParams())

  _updateParams: ->
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
