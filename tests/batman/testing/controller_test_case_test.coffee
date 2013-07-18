class TestController extends Batman.Controller
  routingKey: 'foo'

class TestControllerNoRoutingKey extends Batman.Controller

QUnit.module "Batman.ControllerTestCaseTest", 
  setup: ->
    @testCase = new Batman.ControllerTestCase

  teardown: ->
    Batman.currentApp = null

test 'assertAction checks namedArguments and checks the HTML', ->
  controller = new Batman.Controller()
  view = new Batman.View()
  controller.index = ->

  params = 
    preAction: ->
    postAction: ->
  params.params = { id: 0 }

  sinon.mock(controller).expects('get').withArgs('currentView').returns(view)
  sinon.mock(controller).expects('dispatch').withArgs('index', params.params)
  sinon.stub(view, 'get').returns('<html></html>')

  sinon.mock(view).expects('addToParentNode')
  sinon.mock(view).expects('initializeBindings')
  sinon.mock(params).expects('preAction').once()
  sinon.mock(params).expects('postAction').once()
  
  actionRoute = {}
  actionRoute.namedArguments = [ 'id']
  actionRoute.action = 'index'
  sinon.mock(@testCase).expects('assert').twice()

  @testCase.assertAction controller, actionRoute, params

test 'assertAction fails when the namedArguments is incorrect', ->
  controller = new Batman.Controller()
  view = new Batman.View()
  controller.index = ->

  params = 
    preAction: ->
    postAction: ->
  params.params = {}

  sinon.mock(controller).expects('get').withArgs('currentView').returns(view)
  sinon.mock(controller).expects('dispatch').withArgs('index', params.params)
  sinon.stub(view, 'get').returns('<html></html>')

  sinon.mock(view).expects('addToParentNode')
  sinon.mock(view).expects('initializeBindings')
  sinon.mock(params).expects('preAction').once()
  sinon.mock(params).expects('postAction').once()
  
  actionRoute = {}
  actionRoute.namedArguments = [ 'id']
  actionRoute.action = 'index'
  numCaught = 0
  @testCase.assert = (bool, message) ->
    if message.indexOf( 'named argument') >= 0
      numCaught++
      ok !bool, 'named argument assertion should fire'
    else 
      ok bool

  @testCase.assertAction controller, actionRoute, params
  equal numCaught, 1

test 'assertAction should assert false when initializeBindings throws an error', ->
  controller = new Batman.Controller()
  view = new Batman.View()
  controller.index = ->

  params = 
    preAction: ->
    postAction: ->
  params.params = { id: 0 }

  sinon.mock(controller).expects('get').withArgs('currentView').returns(view)
  sinon.mock(controller).expects('dispatch').withArgs('index', params.params)
  sinon.stub(view, 'get').returns('<html></html>')

  sinon.mock(view).expects('addToParentNode')
  view.initializeBindings = ->
    throw new Error()
  sinon.mock(params).expects('preAction').once()
  sinon.mock(params).expects('postAction').once()
  
  actionRoute = {}
  actionRoute.namedArguments = [ 'id']
  actionRoute.action = 'index'
  numCaught = 0
  @testCase.assert = (bool, message) ->
    if message.indexOf('Caught exception') >= 0
      numCaught++
      ok !bool

  @testCase.assertAction controller, actionRoute, params
  equal numCaught, 1

test 'assertAction should assert false when there is no html', ->
  controller = new Batman.Controller()
  view = new Batman.View()
  controller.index = ->

  view.get = (key) ->
    if key == 'node'
      return '<div/>' 
    else 
      return null

  params = 
    preAction: ->
    postAction: ->

  sinon.stub(controller, 'get').withArgs('currentView').returns(view)
  sinon.stub(controller, 'dispatch')

  sinon.stub(view, 'addToParentNode')
  sinon.stub(view, 'initializeBindings')
  
  actionRoute = {}
  actionRoute.namedArguments = []
  actionRoute.action = 'index'
  numCaught = 0
  @testCase.assert = (bool, message) ->
    if message.indexOf('No HTML for view') >= 0
      numCaught++
      ok !bool

  @testCase.assertAction controller, actionRoute, params
  equal numCaught, 1

test 'assertRoutes constructs a controller class', ->
  @testCase.controllerClass = TestController
  route = 
    childrenByOrder: []
  routeParent = 
    foo: route 
  Batman.currentApp =
    get: -> { childrenByName: routeParent }
    stop: ->

  sinon.mock(TestController).expects('constructor').once()

  @testCase.assertRoutes()

test 'assertRoutes should try to determine controller class based on test class name', ->
  route = 
    childrenByOrder: []
  routeParent = 
    foo: route 
  Batman.currentApp = 
    ControllerCase: TestController
    get: -> { childrenByName: { foo: route } } 
    stop: -> 

  sinon.stub(@testCase, 'assertAction')
  @testCase.assert = (bool, message) ->

  @testCase.assertRoutes()
  equal @testCase.controllerClass, TestController

test 'assertRoutes should assert false if controller class cannot be found', ->
  route = 
    childrenByOrder: []
  routeParent = 
    foo: route 
  Batman.currentApp =
    ControllerCase: null
    get: -> { childrenByName: routeParent }
    stop: ->

  numCaught = 0
  @testCase.assert = (bool, message) =>
    if message.indexOf("Couldn't deduce controller") >= 0
      numCaught++
      ok !bool
      @testCase.controllerClass = TestController

  @testCase.assertRoutes()
  equal @testCase.controllerClass, TestController
  equal numCaught, 1

test 'assertRoutes should assert false if controller routingKey is not set', ->
  @testCase.controllerClass = TestControllerNoRoutingKey
  route = 
    childrenByOrder: []
  routeParent = 
    foo: route 
  Batman.currentApp =
    get: -> { childrenByName: routeParent }
    stop: ->

  numCaught = 0
  @testCase.assert = (bool, message) =>
    if message.indexOf("Routing key isn't set") >= 0
      numCaught++
      ok !bool

  @testCase.assertRoutes()
  equal numCaught, 1

test 'assertRoutes should assert false if there are no routes defined for the controller', ->
  @testCase.controllerClass = TestController
  route = 
    childrenByOrder: []
  routeParent = 
    foo: undefined 
  Batman.currentApp =
    get: -> { childrenByName: routeParent }
    stop: ->

  numCaught = 0
  @testCase.assert = (bool, message) =>
    if message.indexOf("No routes for routing key") >= 0
      numCaught++
      ok !bool

  @testCase.assertRoutes()
  equal numCaught, 1

test 'assertAction is called on the actionRoute.childrenByOrder', ->
  @testCase.controllerClass = TestController
  route = 
    childrenByOrder: [ { action: 'foo'}, { action: 'bar'}]
  routeParent = 
    foo: route 
  Batman.currentApp =
    get: -> { childrenByName: routeParent }
    stop: ->

  params = 
    foo: 'bar'

  sinon.mock(@testCase).expects('assertAction').thrice()
  @testCase.assertRoutes(params)

test 'ControllerTestCase.populateHTML fetches HTML for all routes in currentApp', ->
  sinon.spy( Batman.ControllerTestCase, 'fetchHTML')

  Batman.currentApp =
    get: -> [{ controller: 'TestController', action: 'index' }, { controller: 'TestController', action: 'show' }]
    stop: ->

  Batman.ControllerTestCase.populateHTML('basePath', ->)
  equal Batman.ControllerTestCase.fetchHTML.callCount, 2
