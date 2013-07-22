class TestController extends Batman.Controller
  routingKey: 'foo'
  index: ->
  foo: ->

class TestControllerNoRoutingKey extends Batman.Controller

QUnit.module "Batman.ControllerTestCaseTest", 
  setup: ->
    @testCase = new Batman.ControllerTestCase
    @testCase.controllerClass = TestController
    Batman.currentApp =
      get: ->
        { childrenByOrder: [ { controller: 'foo', action: 'index', namedArguments: [ 'id' ] } ] }
      stop: ->
  
  teardown: ->


test 'dispatch checks namedArguments and checks the HTML', ->
  view = new Batman.View()
  setup = =>
    sinon.mock(@testCase.controller).expects('get').withArgs('currentView').returns(view)
    sinon.mock(@testCase.controller).expects('dispatch').withArgs('index', params.params)

  params = 
    beforeAction: -> setup()
    afterAction: ->
  params.params = { id: 0 }

  sinon.stub(view, 'get').returns('<html></html>')
  view.propagateToSubviews = ->
  sinon.mock(view).expects('addToParentNode')
  sinon.mock(view).expects('initializeBindings')
  
  sinon.mock(@testCase).expects('assert').twice()
  @testCase.dispatch 'index', params

test 'assertAction fails when the namedArguments is incorrect', ->
  view = new Batman.View()
  setup = =>
    sinon.mock(@testCase.controller).expects('get').withArgs('currentView').returns(view)
    sinon.mock(@testCase.controller).expects('dispatch').withArgs('index', params.params)

  params = 
    beforeAction: -> setup()
    afterAction: ->
  params.params = {}
  
  sinon.stub(view, 'get').returns('<html></html>')

  sinon.mock(view).expects('addToParentNode')
  sinon.mock(view).expects('initializeBindings')
  
  numCaught = 0
  @testCase.assert = (bool, message) ->
    if message.indexOf( 'named argument') >= 0
      numCaught++
      ok !bool, 'named argument assertion should fire'
    else 
      ok bool

  @testCase.dispatch 'index', params
  equal numCaught, 1

test 'assertAction should assert false when initializeBindings throws an error', ->
  view = new Batman.View()
  setup = =>
    sinon.mock(@testCase.controller).expects('get').withArgs('currentView').returns(view)
    sinon.mock(@testCase.controller).expects('dispatch').withArgs('index', params.params)

  params = 
    beforeAction: -> setup()
    afterAction: ->

  params.params = { id: 0 }

  sinon.stub(view, 'get').returns('<html></html>')

  sinon.mock(view).expects('addToParentNode')
  view.initializeBindings = ->
    throw new Error()
  numCaught = 0
  @testCase.assert = (bool, message) ->
    if message.indexOf('Caught exception') >= 0
      numCaught++
      ok !bool

  @testCase.dispatch 'index', params
  equal numCaught, 1

test 'assertAction should assert false when there is no html', ->
  view = new Batman.View()

  view.get = (key) ->
    if key == 'node'
      return '<div/>' 
    else 
      return null
  setup = =>
    sinon.mock(@testCase.controller).expects('get').withArgs('currentView').returns(view)
    sinon.mock(@testCase.controller).expects('dispatch')

  params = 
    beforeAction: -> setup()
    afterAction: ->
    params: { id: 1 }

  sinon.stub(view, 'addToParentNode')
  sinon.stub(view, 'initializeBindings')
  
  numCaught = 0
  @testCase.assert = (bool, message) ->
    if message.indexOf('No HTML for view') >= 0
      numCaught++
      ok !bool

  @testCase.dispatch 'index', params
  equal numCaught, 1

test 'ControllerTestCase.populateHTML fetches HTML for all routes in currentApp', ->
  sinon.spy( Batman.ControllerTestCase, 'fetchHTML')

  Batman.currentApp =
    get: -> [{ controller: 'TestController', action: 'index' }, { controller: 'TestController', action: 'show' }]
    stop: ->

  Batman.ControllerTestCase.populateHTML('basePath', ->)
  equal Batman.ControllerTestCase.fetchHTML.callCount, 2
