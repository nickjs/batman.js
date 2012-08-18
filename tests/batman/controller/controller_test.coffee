helpers = if typeof require is 'undefined' then window.viewHelpers else require '../view/view_helper'

class TestController extends Batman.Controller
  show: ->

class MockView extends MockClass
  @chainedCallback 'ready'
  get: createSpy().whichReturns("view contents")
  set: ->
  inUse: -> false

oldNavigator = Batman.navigator

QUnit.module 'Batman.Controller'
  setup: ->
    @controller = new TestController
    @controller.renderCache.reset()
    Batman.DOM.Yield.reset()
    MockView.reset()
  teardown: ->
    delete Batman.currentApp
    Batman.navigator = oldNavigator

test "get('routingKey') should use the prototype level routingKey property", ->
  class ProductsController extends Batman.Controller
    routingKey: 'products'

  equal (new ProductsController).get('routingKey'), 'products'

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

test 'it should render a Batman.View subclass with the ControllerAction name if the routing key is nested', ->
  Batman.currentApp = mockApp = Batman _renderContext: Batman.RenderContext.base
  mockApp.AdminProductsShowView = MockView
  @controller.set 'routingKey', 'admin/products'
  @controller.dispatch 'show'
  view = MockView.lastInstance
  equal view.constructorArguments[0].source, 'admin/products/show'

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

test 'redirecting using @redirect() in an action prevents implicit render', 2, ->
  Batman.navigator = {redirect: createSpy()}
  mockClassDuring Batman ,'View', MockView, (mockClass) =>
    @controller.test = -> @redirect '/'
    @controller.dispatch 'test'
    ok !mockClass.lastInstance
    ok Batman.navigator.redirect.called

test 'redirecting using Batman.redirect in an action prevents implicit render', 2, ->
  Batman.navigator = {redirect: createSpy()}
  mockClassDuring Batman ,'View', MockView, (mockClass) =>
    @controller.test = -> Batman.redirect '/'
    @controller.dispatch 'test'
    ok !mockClass.lastInstance
    ok Batman.navigator.redirect.called

test '@redirect-ing after a dispatch fires no warnings', ->
  Batman.navigator = {redirect: createSpy()}
  @controller.test = -> @render false
  @controller.dispatch 'test'
  @controller.redirect '/'
  ok Batman.navigator.redirect.called

test '@render-ing after a dispatch fires no warnings', 2, ->
  @controller.test = -> @render false
  @controller.dispatch 'test'

  testView = new MockView
  @controller.render view: testView
  spyOnDuring Batman.DOM.Yield.withName('main'), 'replace', (replace) ->
    equal replace.callCount, 0
    testView.fireReady()
    equal replace.callCount, 1

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
    view.fireReady()

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

test 'afterFilters should only fire after renders are complete', 2, ->
  afterSpy = createSpy()

  class TestController extends Batman.Controller
    @afterFilter 'show', afterSpy
    show: -> @render()

  @controller = new TestController

  mockClassDuring Batman ,'View', MockView, (mockClass) =>
    @controller.dispatch 'show'
    view = mockClass.lastInstance
    ok !afterSpy.called
    view.fireReady()
    ok afterSpy.called

test 'afterFilters on outer actions should fire after afterFilters on inner actions', 1, ->
  order = []
  class TestController extends Batman.Controller
    @afterFilter 'show', -> order.push 1
    @afterFilter 'test', -> order.push 2
    show: -> @render false
    test: ->
      @render false
      @executeAction 'show'

  @controller = new TestController
  @controller.dispatch 'test'
  deepEqual order, [1, 2]

test 'afterFilters on outer actions should only fire after inner renders are complete', 2, ->
  afterSpy = createSpy()

  class TestController extends Batman.Controller
    @afterFilter 'test', afterSpy
    show: -> @render()
    test: ->
      @render false
      @executeAction 'show'

  @controller = new TestController

  mockClassDuring Batman ,'View', MockView, (mockClass) =>
    @controller.dispatch 'test'
    view = mockClass.lastInstance
    ok !afterSpy.called
    view.fireReady()
    ok afterSpy.called

test 'afterFilters on outer actions should fire after afterFilters on inner actions', 1, ->
  order = []
  class TestController extends Batman.Controller
    @afterFilter 'show', -> order.push 1
    @afterFilter 'test', -> order.push 2
    show: -> @render false
    test: ->
      @render false
      @executeAction 'show'

  @controller = new TestController
  @controller.dispatch 'test'
  deepEqual order, [1, 2]

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
