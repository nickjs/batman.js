class Batman.ControllerTestCase extends Batman.TestCase
  @mixin Batman.ModelExpectations

  assertRoutes: (controller, params = {}) ->
    throw new Error("Routing key isn't set") if not controller.routingKey

    actionRoutes = Batman.currentApp.get('routes.routeMap').childrenByName[controller.routingKey]
    throw new Error("No routes for routing key: #{controller.routingKey}") if not actionRoutes
    
    assertedActions = actionRoutes.childrenByOrder
    for action of params
      if assertedActions.filter( (a) ->  action == a.action ).length == 0
        assertedActions.push({ action: action, namedArguments: [] })

    for action in assertedActions
      @assertAction(controller, action, params[action.action])
      assertedActions.push(action.action)

  assertAction: (controller, actionRoute, params = {}) ->
    @assertEqual 'function', typeof controller[actionRoute.action], "Action: #{actionRoute.action} doesn't exist!"
    for namedArg in actionRoute.namedArguments
      @assert namedArg of params.params, "named argument: #{namedArg} doesn't exist in parameters"
    
    params.beforeAction?(controller)
    try
      controller.dispatch actionRoute.action, params.params
      currentView = controller.get('currentView')
      @assert currentView.get('html'), "No HTML for view"
      div = document.createElement('div')
      document.body.appendChild(div)
      currentView.get('node')
      currentView.subviews = new Batman.SimpleSet() 
      currentView.addToParentNode(div)
      currentView.propagateToSubviews('viewWillAppear')
      currentView.initializeBindings()
      currentView.propagateToSubviews('isInDOM', true)
      currentView.propagateToSubviews('viewDidAppear')
      Batman.setImmediate ->
    catch e
      @assert false, "Caught exception in view bindings: #{e.toString()}"
    finally
      document.body.removeChild(div)

    params.afterAction?(controller)
    null

  @fetchHTML: (basePath, path, callback) ->
    $.ajax( {
      url: "#{basePath}/#{path}.js.htm"
      method: 'GET'
      success: (data) ->
        callback(data, path)
      error: ->
        callback(undefined)
      } )

  @populateHTML: (basePath, callback) ->
    routes = Batman.currentApp.get('routes.routeMap.childrenByOrder')
    numRoutes = routes.length
    for route in routes
      @fetchHTML basePath, "#{route.controller}/#{route.action}", (data, path) ->
        Batman.View.store.set(Batman.Navigator.normalizePath(path), data)
        numRoutes -= 1
        if numRoutes == 0 
          callback()
