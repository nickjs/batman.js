module.exports = class RouteMap
  memberRoute: null
  collectionRoute: null

  constructor: ->
    @childrenByOrder = []
    @childrenByName = {}

  routeForParams: (params) ->
    @_cachedRoutes ||= {}
    key = @cacheKey(params)

    if @_cachedRoutes[key]
      @_cachedRoutes[key]
    else
      for route in @childrenByOrder
        return (@_cachedRoutes[key] = route) if route.test(params)

  addRoute: (name, route) ->
    @childrenByOrder.push(route)
    if name.length > 0 && (names = name.split('.')).length > 0
      base = names.shift()
      unless @childrenByName[base]
        @childrenByName[base] = new RouteMap
      @childrenByName[base].addRoute(names.join('.'), route)
    else
      if route.get('member')
        Batman.developer.do =>
          Batman.developer.error("Member route with name #{name} already exists!") if @memberRoute
        @memberRoute = route
      else
        Batman.developer.do =>
          Batman.developer.error("Collection route with name #{name} already exists!") if @collectionRoute
        @collectionRoute = route
    true

   cacheKey: (params) ->
    if typeof params is 'string'
      params
    else if params.path?
      params.path
    else
      "#{params.controller}##{params.action}"
