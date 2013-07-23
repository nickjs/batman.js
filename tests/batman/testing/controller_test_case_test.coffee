class TestController extends Batman.Controller
  @view: new Batman.View
  routingKey: 'foo'
  index: ->
  foo: ->
  get: (key) ->
    return TestController.view if key == 'currentView'
    return '<html>'
  dispatch: ->

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
  params = {}
  params.params = { id: 0 }

  TestController.view.propagateToSubviews = ->
  sinon.mock(TestController.view).expects('addToParentNode')
  sinon.mock(TestController.view).expects('initializeBindings')
  
  sinon.mock(@testCase).expects('assert').twice()
  @testCase.dispatch 'index', params

test 'assertAction fails when the namedArguments is incorrect', ->
  view = new Batman.View()
  params = {}
  params.params = {}
  numCaught = 0
  @testCase.assert = (bool, message) ->
    if message.indexOf( 'named argument') >= 0
      numCaught++
      ok !bool, 'named argument assertion should fire'

  @testCase.dispatch 'index', params
  equal numCaught, 1

test 'assertAction should assert false when initializeBindings throws an error', ->
  params = {}
  params.params = { id: 0 }

  TestController.view.initializeBindings = ->
    throw new Error()
  numCaught = 0
  @testCase.assert = (bool, message) ->
    if message.indexOf('exception was raised') >= 0
      numCaught++
      ok !bool

  @testCase.dispatch 'index', params
  equal numCaught, 1

test 'assertAction should assert false when there is no html', ->
  params = 
    params: { id: 1 }

  numCaught = 0
  @testCase.assert = (bool, message) ->
    if message.indexOf('No HTML for view') >= 0
      numCaught++
      ok !bool

  @testCase.dispatch 'index', params
  equal numCaught, 1
