class TestController extends Batman.Controller
  show: ->

class MockView extends MockClass
  @chainedCallback 'ready'
  get: createSpy().whichReturns("view contents")
  set: ->
  inUse: -> false

QUnit.module 'Batman.Controller'

test "get('routingKey') should use the prototype level routingKey property", ->
  class ProductsController extends Batman.Controller
    routingKey: 'products'

  equal (new ProductsController).get('routingKey'), 'products'

QUnit.module 'Batman.Controller render'
  setup: ->
    Batman.Controller::renderCache = new Batman.RenderCache
    @controller = new TestController
    Batman.DOM.Yield.reset()
  teardown: ->
    delete Batman.currentApp

test 'it should render a Batman.View if `view` isn\'t given in the options to render', ->
  mockClassDuring Batman ,'View', MockView, (mockClass) =>
    @controller.dispatch 'show'
    view = mockClass.lastInstance
    equal view.constructorArguments[0].source, 'test/show'

    spyOnDuring Batman.DOM.Yield.withName('main'), 'replace', (replace) =>
      view.fireReady()
      deepEqual view.get.lastCallArguments, ['node']
      deepEqual replace.lastCallArguments, ['view contents']

test 'it should cache the rendered Batman.View if `view` isn\'t given in the options to render', ->
  mockClassDuring Batman ,'View', MockView, (mockClass) =>
    @controller.dispatch 'show'
    view = mockClass.lastInstance

    @controller.dispatch 'show'
    equal mockClass.lastInstance, view, "No new instance has been made"

test 'it should cycle and clearStale all yields after dispatch', ->
  spyOnDuring Batman.DOM.Yield.withName('sidebar'), 'cycle', (sidebarCycleSpy) =>
    spyOnDuring Batman.DOM.Yield.withName('main'), 'cycle', (mainCycleSpy) =>
      mockClassDuring Batman ,'View', MockView, (mockClass) =>
        @controller.show = ->
          @render {into: 'main'}
        @controller.index = ->
          @render {into: 'sidebar'}

        equal mainCycleSpy.callCount, 0
        equal sidebarCycleSpy.callCount, 0
        @controller.dispatch 'show'
        equal mainCycleSpy.callCount, 1
        equal sidebarCycleSpy.callCount, 1
        @controller.dispatch 'index'
        equal mainCycleSpy.callCount, 2
        equal sidebarCycleSpy.callCount, 2

test 'it should render a Batman.View subclass with the ControllerAction name on the current app if it exists', ->
  Batman.currentApp = mockApp = Batman _renderContext: Batman.RenderContext.base
  mockApp.TestShowView = MockView

  @controller.dispatch 'show'
  view = MockView.lastInstance
  equal view.constructorArguments[0].source, 'test/show'

  spyOnDuring Batman.DOM.Yield.withName('main'), 'replace', (replace) =>
    view.fireReady()
    deepEqual view.get.lastCallArguments, ['node']
    deepEqual replace.lastCallArguments, ['view contents']

test 'it should cache the rendered Batman.Views if rendered from different action', ->
  Batman.currentApp = mockApp = Batman _renderContext: Batman.RenderContext.base
  @controller.actionA = ->
    @render viewClass: MockView, source: 'foo'
  @controller.actionB = ->
    @render viewClass: MockView, source: 'foo'

  @controller.dispatch 'actionA'
  view = MockView.lastInstance

  @controller.dispatch 'actionB'
  equal MockView.lastInstance, view, "No new instance has been made"

asyncTest 'it should cache the rendered Batman.Views if rendered from different actions into different yields', ->
  Batman.currentApp = mockApp = Batman _renderContext: Batman.RenderContext.base
  mainContainer = $('<div>')[0]
  detailContainer = $('<div>')[0]
  Batman.DOM.Yield.withName('main').set 'containerNode', mainContainer
  Batman.DOM.Yield.withName('detail').set 'containerNode', detailContainer

  @controller.index = ->
    @render viewClass: Batman.View, html: 'foo', into: 'main', source: 'a'

  @controller.show = ->
    @index()
    @render viewClass: Batman.View, html: 'bar', into: 'detail', source: 'b'

  @controller.dispatch 'index'
  delay =>
    mainView = Batman._data mainContainer.childNodes[0], 'view'
    @controller.dispatch 'show'
    delay ->
      equal Batman._data(mainContainer.childNodes[0], 'view'), mainView, "The same view was used in the second dispatch"

test 'it should render views if given in the options', ->
  testView = new MockView
  @controller.render
    view: testView

  spyOnDuring Batman.DOM.Yield.withName('main'), 'replace', (replace) =>
    testView.fireReady()
    deepEqual testView.get.lastCallArguments, ['node']
    deepEqual replace.lastCallArguments, ['view contents']

test 'it should allow setting the default render destination yield', ->
  testView = new MockView
  @controller.defaultRenderYield = 'sidebar'
  @controller.render
    view: testView

  spyOnDuring Batman.DOM.Yield.withName('sidebar'), 'replace', (replace) =>
    testView.fireReady()
    deepEqual replace.lastCallArguments, ['view contents']

test 'it should pull in views if not present already', ->
  mockClassDuring Batman ,'View', MockView, (mockClass) =>
    @controller.dispatch 'show'
    view = mockClass.lastInstance
    equal view.constructorArguments[0].source, 'test/show'

    spyOnDuring Batman.DOM.Yield.withName('main'), 'replace', (replace) =>
      view.fireReady()
      deepEqual view.get.lastCallArguments, ['node']
      deepEqual replace.lastCallArguments, ['view contents']

test 'dispatching routes without any actions calls render', 1, ->
  @controller.test = ->
  @controller.render = ->
    ok true, 'render called'

  @controller.dispatch 'test'

test '@render false disables implicit render', 2, ->
  @controller.test = ->
    ok true, 'action called'
    @render false

  spyOnDuring Batman.DOM, 'replace', (replace) =>
    @controller.dispatch 'test'
    ok ! replace.called

test 'event handlers can render after an action', 6, ->
  testView = new MockView
  @controller.test = ->
    ok true, 'action called'
    @render view: testView

  testView2 = new MockView
  @controller.handleEvent = ->
    ok true, 'event called'
    @render view: testView2

  testView3 = new MockView
  @controller.handleAnotherEvent = ->
    ok true, 'another event called'
    @render view: testView3

  @controller.dispatch 'test'
  spyOnDuring Batman.DOM.Yield.withName('main'), 'replace', (replace) =>
    testView.fire 'ready'
    equal replace.callCount, 1

    @controller.handleEvent()
    testView2.fire 'ready'
    equal replace.callCount, 2

    @controller.handleAnotherEvent()
    testView3.fire 'ready'
    equal replace.callCount, 3

test 'redirecting a dispatch prevents implicit render', 2, ->
  Batman.navigator = new Batman.HashbangNavigator
  Batman.navigator.redirect = ->
    ok true, 'redirecting history manager'
  @controller.render = ->
    ok true, 'redirecting controller'
  @controller.render = ->
    throw "shouldn't be called"

  @controller.test1 = ->
    @redirect 'foo'

  @controller.test2 = ->
    Batman.redirect 'foo2'

  @controller.dispatch 'test1'
  @controller.dispatch 'test2'

test 'filters specifying no restrictions should be called on all actions', 2, ->
  spy = createSpy()
  class FilterController extends Batman.Controller
    @beforeFilter spy

    show: -> @render false
    index: -> @render false

  controller = new FilterController

  controller.dispatch 'show'
  equal spy.callCount, 1
  controller.dispatch 'index'
  equal spy.callCount, 2

test 'filters specifying only should only be called on those actions', 2, ->
  spy = createSpy()

  class FilterController extends Batman.Controller
    @beforeFilter only: 'withBefore', spy

    withBefore: -> @render false
    all: -> @render false

  controller = new FilterController

  controller.dispatch 'withBefore'
  equal spy.callCount, 1
  controller.dispatch 'all'
  equal spy.callCount, 1

test 'filters specifying except should not be called on those actions', 2, ->
  spy = createSpy()
  class FilterController extends Batman.Controller
    @beforeFilter except: 'index', spy

    show: -> @render false
    index: -> @render false

  controller = new FilterController

  controller.dispatch 'show'
  equal spy.callCount, 1
  controller.dispatch 'index'
  equal spy.callCount, 1

test 'filters specifying options in arrays should apply to all/none of those options', 3, ->
  spy = createSpy()
  class FilterController extends Batman.Controller
    @beforeFilter except: ['index', 'edit'], spy

    show: -> @render false
    index: -> @render false
    edit: -> @render false

  controller = new FilterController

  controller.dispatch 'edit'
  equal spy.callCount, 0
  controller.dispatch 'show'
  equal spy.callCount, 1
  controller.dispatch 'index'
  equal spy.callCount, 1

test 'actions executed by other actions implicitly render', ->
  mockClassDuring Batman ,'View', MockView, (mockClass) =>
    @controller.test = ->
      @render false
      @executeAction 'show'

    @controller.dispatch 'test'

    view = mockClass.lastInstance # instantiated by the show implicit render
    equal view.constructorArguments[0].source, 'test/show', "The action is correctly different inside the inner execution"

test 'actions executed by other actions have their filters run', ->
  beforeSpy = createSpy()
  afterSpy = createSpy()

  class TestController extends Batman.Controller
    @beforeFilter 'show', beforeSpy
    @afterFilter 'show', afterSpy

    show: -> @render false
    test: ->
      @render false
      @executeAction 'show'

  @controller = new TestController
  @controller.dispatch 'test'
  ok beforeSpy.called
  ok afterSpy.called

test 'dispatching params with a hash scrolls to that hash', ->
  @controller.show = -> @render false

  spyOnDuring Batman.DOM, 'scrollIntoView', (spy) =>
    spy.fixedReturn = true
    @controller.dispatch 'show', {'#': 'foo'}
    deepEqual spy.lastCallArguments, ['foo']

test 'dispatching params with a hash does not scroll to that hash if autoScrollToHash is false', ->
  @controller.autoScrollToHash = false
  @controller.show = -> @render false

  spyOnDuring Batman.DOM, 'scrollIntoView', (spy) =>
    spy.fixedReturn = true
    @controller.dispatch 'show', {'#': 'foo'}
    ok !spy.called
