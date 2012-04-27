#= require ../object

class Batman.NamedRouteQuery extends Batman.Object
  isNamedRouteQuery: true

  constructor: (routeMap, args = []) ->
    super({routeMap, args})
    for key of @get('routeMap').childrenByName
      @[key] = @_queryAccess.bind(@, key)

  @accessor 'route', ->
    {memberRoute, collectionRoute} = @get('routeMap')
    for route in [memberRoute, collectionRoute] when route?
      return route if route.namedArguments.length == @get('args').length
    return collectionRoute || memberRoute

  @accessor 'path', -> @path()

  @accessor 'routeMap', 'args', 'cardinality', Batman.Property.defaultAccessor

  @accessor
    get: (key) ->
      return if !key?
      if typeof key is 'string'
        @nextQueryForName(key)
      else
        @nextQueryWithArgument(key)
    set: ->
    cache: false

  nextQueryForName: (key) ->
    if map = @get('routeMap').childrenByName[key]
      return new Batman.NamedRouteQuery(map, @args)
    else
      Batman.developer.error "Couldn't find a route for the name #{key}!"

  nextQueryWithArgument: (arg) ->
    args = @args.slice(0)
    args.push arg
    @clone(args)

  path: ->
    params = {}
    namedArguments = @get('route.namedArguments')
    for argumentName, index in namedArguments
      if (argumentValue = @get('args')[index])?
        params[argumentName] = @_toParam(argumentValue)

    @get('route').pathFromParams(params)

  toString: -> @path()

  clone: (args = @args) -> new Batman.NamedRouteQuery(@routeMap, args)

  _toParam: (arg) ->
    if arg instanceof Batman.AssociationProxy
      arg = arg.get('target')
    if arg?.toParam? then arg.toParam() else arg

  _queryAccess: (key, arg) ->
    query = @nextQueryForName(key)
    if arg?
      query = query.nextQueryWithArgument(arg)
    query
