class Batman.ControllerTestCase extends Batman.TestCase
  @mixin Batman.ModelExpectations

  dispatch: (action, params = {}) ->
    @controllerClass ||= Batman.currentApp[@constructor.name.replace(/Test/,'')]
    if not @controllerClass
      throw new Error( "Unable to deduce controller class name from test class. Please set @controllerClass if not conventional" )

    @controller = params.controller || new @controllerClass
    controllerName = Batman.helpers.camelize(@controllerClass.name.replace(/Controller/,''), true)
    routeMap = Batman.currentApp.get('routes.routeMap')
    actionRoutes = routeMap.childrenByOrder.filter( (route) => route.controller == controllerName and route.action ==  action)

    if actionRoutes.length == 0
      @assert false, "Route doesn't exist for action"
      return
    
    if actionRoutes[0].namedArguments.length > 0
      @assert params.params, 'params are required for action'

    for namedRoute in actionRoutes[0].namedArguments
      @assert namedRoute of params.params, 'named argument mismatch'
    
    @assertEqual 'function', typeof @controller[action], "Action: #{action} doesn't exist!"
    try
      @controller.dispatch action, params.params
      currentView = @controller.get('currentView')
      @assert currentView.get('html'), "No HTML for view"
      div = document.createElement('div')
      document.body.appendChild(div)
      currentView.get('node')
      currentView.addToParentNode(div)
      currentView.propagateToSubviews('viewWillAppear')
      currentView.initializeBindings()
      currentView.propagateToSubviews('isInDOM', true)
      currentView.propagateToSubviews('viewDidAppear')
    catch e
      @assert false, "exception was raised in view bindings: #{e.toString()}"
    finally
      document.body.removeChild(div) if div?
      
    null

