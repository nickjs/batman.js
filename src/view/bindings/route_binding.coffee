#= require abstract_binding

class Batman.DOM.RouteBinding extends Batman.DOM.AbstractBinding
  onATag: false

  @accessor 'dispatcher', ->
    @renderContext.get('dispatcher') || Batman.App.get('current.dispatcher')

  bind: ->
    if @node.nodeName.toUpperCase() is 'A'
      @onATag = true
    super
    Batman.DOM.events.click @node, (node, event) =>
      return if event.__batmanActionTaken
      event.__batmanActionTaken = true
      params = @pathFromValue(@get('filteredValue'))
      Batman.redirect params if params?

  dataChange: (value) ->
    if value?
      path = @pathFromValue(value)

    if @onATag
      if path?
        path = Batman.navigator.linkTo path
      else
        path = "#"
      @node.href = path

  pathFromValue: (value) ->
    if value?
      if value.isNamedRouteQuery
        value.get('path')
      else
        @get('dispatcher')?.pathFromParams(value)

