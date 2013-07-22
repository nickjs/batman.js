class Batman.ControllerTestCase extends Batman.TestCase
  @mixin Batman.ModelExpectations

  dispatch: (action, params = {}) ->
    @controllerClass ||= Batman.currentApp[@constructor.name.replace(/Test/,'')]
    if not @controllerClass
      throw new Error( "Couldn't deduce controller name" )

    @controller = new @controllerClass

    routeMap = Batman.currentApp.get('routes.routeMap')
    actionRoutes = routeMap.childrenByOrder.filter( (route) => route.controller == @controller.routingKey and route.action ==  action)

    if actionRoutes.length == 0
      throw new Error( "Route doesn't exist for action" )

    for namedRoute in actionRoutes[0].namedArguments
      @assert namedRoute of params.params, 'named argument mismatch'
    
    params.beforeAction?()
    @assertEqual 'function', typeof @controller[action], "Action: #{action} doesn't exist!"
    try
      @controller.dispatch action, params.params
      currentView = @controller.get('currentView')
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
    catch e
      @assert false, "Caught exception in view bindings: #{e.toString()}"
    finally
      document.body.removeChild(div)
      
    params.afterAction?()
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
