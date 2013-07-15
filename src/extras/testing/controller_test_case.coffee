class Batman.ControllerTestCase extends Batman.TestCase
  @mixin Batman.ModelExpectations

  assertRoutes: (params = {}) ->
    @controllerClass ||= Batman.currentApp[@constructor.name.replace(/Test/, '')]
    @assert @controllerClass, "Couldn't deduce controller name from test case, please assign it via @controllerClass"
    
    controller = new @controllerClass
    @assert controller.routingKey, "Routing key isn't set"
    
    actionRoutes = Batman.currentApp.get('routes.routeMap').childrenByName[controller.routingKey]
    @assert actionRoutes, "No routes for routing key: #{controller.routingKey}"
    
    assertedActions = []
    for action in actionRoutes.childrenByOrder
      @assertAction(controller, action, params.action)
      assertedActions.push(action.action)

    #unnamed routes, user specified actions to run through dispatch
    for action of params
      if not action in assertedActions
        @assertedAction(controller, { action: action }, params.action )

  assertAction: (controller, actionRoute, params = {}) ->
    @assertEqual 'function', typeof controller[actionRoute.action], "Action: #{actionRoute.action} doesn't exist!"
    for namedArg in actionRoute.namedArguments
      @assert params.params[namedArg], "named argument: #{namedArg} doesn't exist in parameters"
    
    params.preAction?()
    controller.dispatch actionRoute.action, params.params
    params.postAction?()
    null
