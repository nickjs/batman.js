class Batman.RouteMap
  memberRoute: null
  collectionRoute: null

  constructor: ->
    @childrenByOrder = []
    @childrenByName = {}

  routeForParams: (params) ->
    for route in @childrenByOrder
      return route if route.test(params)

    return undefined

  addRoute: (name, route) ->
    @childrenByOrder.push(route)
    if name.length > 0 && (names = name.split('.')).length > 0
      base = names.shift()
      unless @childrenByName[base]
        @childrenByName[base] = new Batman.RouteMap
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
