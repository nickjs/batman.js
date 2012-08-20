#= require ../object

class Batman.Dispatcher extends Batman.Object
  @canInferRoute: (argument) ->
    argument instanceof Batman.Model ||
    argument instanceof Batman.AssociationProxy ||
    argument.prototype instanceof Batman.Model

  @paramsFromArgument: (argument) ->
    resourceNameFromModel = (model) ->
      Batman.helpers.camelize(Batman.helpers.pluralize(model.get('resourceName')), true)

    return argument unless @canInferRoute(argument)

    if argument instanceof Batman.Model || argument instanceof Batman.AssociationProxy
      argument = argument.get('target') if argument.isProxy
      if argument?
        {
          controller: resourceNameFromModel(argument.constructor)
          action: 'show'
          id: argument.get('id')
        }
      else
        {}
    else if argument.prototype instanceof Batman.Model
      {
        controller: resourceNameFromModel(argument)
        action: 'index'
      }
    else
      argument

  class ControllerDirectory extends Batman.Object
    @accessor '__app', Batman.Property.defaultAccessor
    @accessor (key) -> @get("__app.#{Batman.helpers.capitalize(key)}Controller.sharedController")

  @accessor 'controllers', -> new ControllerDirectory(__app: @get('app'))

  constructor: (app, routeMap) ->
    super({app, routeMap})

  routeForParams: (params) ->
    params = @constructor.paramsFromArgument(params)
    @get('routeMap').routeForParams(params)

  pathFromParams: (params) ->
    return params if typeof params is 'string'
    params = @constructor.paramsFromArgument(params)
    @routeForParams(params)?.pathFromParams(params)

  dispatch: (params) ->
    inferredParams = @constructor.paramsFromArgument(params)
    route = @routeForParams(inferredParams)

    if route
      [path, params] = route.pathAndParamsFromArgument(inferredParams)

      @set 'app.currentRoute', route
      @set 'app.currentURL', path
      @get('app.currentParams').replace(params or {})

      route.dispatch(params)
    else
      # No route matching the parameters was found, but an object which might be for
      # use with the params replacer has been passed. If its an object like a model
      # or a record we could have inferred a route for it (but didn't), so we make
      # sure that it isn't by running it through canInferRoute.
      if Batman.typeOf(params) is 'Object' && !@constructor.canInferRoute(params)
        return @get('app.currentParams').replace(params)
      else
        @get('app.currentParams').clear()

      error =
        type: '404'
        isPrevented: false
        preventDefault: -> @isPrevented = true

      Batman.currentApp?.fire 'error', error
      return params if error.isPrevented
      return Batman.redirect('/404') unless params is '/404'

    path
