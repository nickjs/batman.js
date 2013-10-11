#= require ./abstract_binding

class Batman.DOM.RouteBinding extends Batman.DOM.AbstractBinding
  onAnchorTag: false
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  @accessor 'dispatcher', ->
    @view.lookupKeypath('dispatcher') || Batman.App.get('current.dispatcher')

  constructor: ->
    super

    if paramKeypath = @node.getAttribute('data-route-params')
      definition = new Batman.DOM.ReaderBindingDefinition(@node, paramKeypath, @view)
      @set('queryParams', new Batman.DOM.RouteParamsBinding(definition, this))

  bind: ->
    if @node.nodeName in ['a','A']
      @onAnchorTag = true

    super

    return if @onAnchorTag && @node.getAttribute('target')
    Batman.DOM.events.click(@node, @routeClick)

  routeClick: (node, event) =>
    return if event.__batmanActionTaken
    event.__batmanActionTaken = true

    path = @generatePath(@get('filteredValue'), @get('queryParams.filteredValue'))
    Batman.redirect(path) if path?

  dataChange: (value, node, queryParams) ->
    if value
      path = @generatePath(value, queryParams || @get('queryParams.filteredValue'))

    if @onAnchorTag
      if path and Batman.navigator
        path = Batman.navigator.linkTo(path)
      else
        path = "#"

      @node.href = path

  generatePath: (value, params) ->
    path = if value?.isNamedRouteQuery
        value.get('path')
      else
        @get('dispatcher')?.pathFromParams(value)

    return path if !params || !path

    if Batman.typeOf(params) == 'String'
      return if path.indexOf('?') == -1
        path += "?#{params}"
      else
        path += "&#{params}"

    for key, val of params
      path = if path.indexOf('?') == -1
        path += "?#{key}=#{val}"
      else
        path += "&#{key}=#{val}"

    return path

class Batman.DOM.RouteParamsBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition, @routeBinding) ->
    super(definition)

  dataChange: (value) ->
    @routeBinding.dataChange(@routeBinding.get('filteredValue'), @node, value)
