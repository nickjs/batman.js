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

test 'redirect() in beforeFilter halts chain and does not call action or render', 4, ->
  beforeSpy1 = createSpy()
  beforeSpy2 = createSpy()
  renderSpy = createSpy()
  afterSpy = createSpy()

  class FilterController extends Batman.Controller
    @beforeFilter beforeSpy1
    @beforeFilter ->
      @redirect '/'
    @beforeFilter beforeSpy2
    @afterFilter afterSpy

    render: renderSpy
    index: -> @render false

  controller = new FilterController
  controller.dispatch 'index'
  equal beforeSpy1.callCount, 1
  equal beforeSpy2.callCount, 0
  equal renderSpy.callCount, 0
  equal afterSpy.callCount, 0

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

test 'beforeFilters and afterFilters are inherited when subclassing controllers', 8, ->
  beforeSpy1 = createSpy()
  beforeSpy2 = createSpy()
  afterSpy1 = createSpy()
  afterSpy2 = createSpy()

  class TestParentController extends Batman.Controller
    @beforeFilter beforeSpy1
    @beforeFilter 'show', beforeSpy2
    @afterFilter afterSpy1
    @afterFilter 'show', afterSpy2

    show: -> @render false

  beforeSpy3 = createSpy()
  beforeSpy4 = createSpy()
  afterSpy3 = createSpy()
  afterSpy4 = createSpy()
  
  class TestChildController extends TestParentController
    @beforeFilter beforeSpy3
    @beforeFilter 'show', beforeSpy4
    @afterFilter afterSpy3
    @afterFilter 'show', afterSpy4

  controller = new TestChildController
  controller.dispatch 'show'

  equal beforeSpy1.callCount, 1
  equal beforeSpy2.callCount, 1
  equal beforeSpy3.callCount, 1
  equal beforeSpy4.callCount, 1

  equal afterSpy1.callCount, 1
  equal afterSpy2.callCount, 1
  equal afterSpy3.callCount, 1
  equal afterSpy4.callCount, 1

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

QUnit.module 'Batman.Controller error handling'
  setup: ->
    class @CustomError extends Batman.Object
    class @CustomError2 extends Batman.Object

    @error = error = new @CustomError
    @error2 = error2 = new @CustomError2

    class @Model extends Batman.Object
      @load: (callback) ->
        callback(error, undefined)
      @load2: (callback) ->
        callback(error2, undefined)

    class @TestController extends Batman.Controller
      _customErrorHandler: (err) ->
      _customErrorHandler2: (err) ->    
   
test 'When wrapping a call with the errorHandler callback, any exception tracked with catchError will be handled by a single handler', 3, ->
  callbackSpy = createSpy()
  handlerSpy = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController.catchError @CustomError, with: @TestController::_customErrorHandler

  namespace = @
  controller = new @TestController
  controller.index = -> 
    namespace.Model.load @errorHandler callbackSpy
    @render false
  controller.dispatch('index')

  equal callbackSpy.callCount, 0
  equal handlerSpy.callCount, 1
  deepEqual handlerSpy.lastCallArguments, [@error]
  
test 'When wrapping a call with the errorHandler callback, any exception tracked with catchError will be handled by multiple handlers', 5, ->
  callbackSpy = createSpy()
  handlerSpy = createSpy()
  handlerSpy2 = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController::_customErrorHandler2 = handlerSpy2
  @TestController.catchError @CustomError, with: [@TestController::_customErrorHandler, @TestController::_customErrorHandler2]

  namespace = @
  controller = new @TestController
  controller.index = -> 
    namespace.Model.load @errorHandler callbackSpy
    @render false
  controller.dispatch('index')

  equal callbackSpy.callCount, 0
  equal handlerSpy.callCount, 1
  equal handlerSpy2.callCount, 1
  deepEqual handlerSpy.lastCallArguments, [@error]
  deepEqual handlerSpy2.lastCallArguments, [@error]

test 'When wrapping a call with the errorHandler callback, any exception that is not tracked with specific catchError will be re-thrown', 3, ->
  callbackSpy = createSpy()
  handlerSpy = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController.catchError @CustomError, with: @TestController::_customErrorHandler
  
  @Model.load = (callback) ->
    callback(new Error, undefined)
  namespace = @
  controller = new @TestController
  controller.index = ->
    namespace.Model.load @errorHandler callbackSpy
    @render false

  raises ->
    controller.dispatch('index')
  , Error

  equal callbackSpy.callCount, 0
  equal handlerSpy.callCount, 0

test 'When wrapping a call with the errorHandler callback, no exception passes result to callback', 3, ->
  callbackSpy = createSpy()
  handlerSpy = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController.catchError @CustomError, with: @TestController::_customErrorHandler
  
  @Model.load = (callback) ->
    callback(undefined, [{id: 1}], 'foo')
  namespace = @
  controller = new @TestController
  controller.index = ->
    namespace.Model.load @errorHandler callbackSpy
    @render false
  
  controller.dispatch('index')

  equal handlerSpy.callCount, 0
  equal callbackSpy.callCount, 1
  deepEqual callbackSpy.lastCallArguments, [[{id: 1}], 'foo']

test 'subclass errors registered with superclass catchError cause the errorHandler callback to fire', 3, ->
  class ReallyCustomError extends @CustomError

  callbackSpy = createSpy()
  handlerSpy = createSpy()
  error = new ReallyCustomError

  @TestController::_customErrorHandler = handlerSpy
  @TestController.catchError @CustomError, with: @TestController::_customErrorHandler

  @Model.load = (callback) ->
    callback(error, undefined)
  namespace = @
  controller = new @TestController 
  controller.index = ->
    namespace.Model.load @errorHandler callbackSpy
    @render false
  controller.dispatch('index')

  equal callbackSpy.callCount, 0
  equal handlerSpy.callCount, 1
  deepEqual handlerSpy.lastCallArguments, [error]

test 'When wrapping a call with the errorHandler callback, parent class handlers are also called', 7, ->
  callbackSpy = createSpy()
  handlerSpy = createSpy()
  handlerSpy2 = createSpy()
  handlerSpy3 = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController::_customErrorHandler2 = handlerSpy2
  @TestController.catchError @CustomError, with: [@TestController::_customErrorHandler, @TestController::_customErrorHandler2]

  namespace = @

  class SubclassController extends @TestController
    _customErrorHandler3: handlerSpy3
    _customErrorHandler2: handlerSpy2
    @catchError namespace.CustomError, with: @::_customErrorHandler3 
    
  namespace = @
  controller = new SubclassController
  controller.index = -> 
    namespace.Model.load @errorHandler callbackSpy
    @render false
  
  controller.dispatch('index')

  equal callbackSpy.callCount, 0
  equal handlerSpy.callCount, 1
  equal handlerSpy2.callCount, 1
  equal handlerSpy3.callCount, 1
  deepEqual handlerSpy.lastCallArguments, [@error]
  deepEqual handlerSpy2.lastCallArguments, [@error]
  deepEqual handlerSpy3.lastCallArguments, [@error]

test 'When wrapping multiple calls with errorHandler callback, any successive calls to the errorHandler should be ignored if an error occured on the current frame', 4, ->
  callbackSpy = createSpy()
  handlerSpy = createSpy()
  handlerSpy2 = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController::_customErrorHandler2 = handlerSpy2
  @TestController.catchError @CustomError, with: [@TestController::_customErrorHandler]
  @TestController.catchError @CustomError2, with: [@TestController::_customErrorHandler2]

  namespace = @
  controller = new @TestController
  controller.index = ->
    namespace.Model.load @errorHandler callbackSpy
    namespace.Model.load2 @errorHandler callbackSpy
    @render false

  controller.dispatch('index')

  equal handlerSpy.callCount, 1
  equal handlerSpy2.callCount, 0
  equal callbackSpy.callCount, 0
  deepEqual handlerSpy.lastCallArguments, [@error]

test 'When wrapping multiple nested calls with errorHandler callback, nested errors should not be fired if parent errored', 4, ->
  callbackSpy = createSpy()
  handlerSpy = createSpy()
  handlerSpy2 = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController::_customErrorHandler2 = handlerSpy2
  @TestController.catchError @CustomError, with: [@TestController::_customErrorHandler]
  @TestController.catchError @CustomError2, with: [@TestController::_customErrorHandler2]

  namespace = @
  controller = new @TestController
  controller.index = ->
    namespace.Model.load @errorHandler ->
      namespace.Model.load2 @errorHandler callbackSpy
      ok false # should not be called
    @render false

  controller.dispatch('index')

  equal handlerSpy.callCount, 1
  equal handlerSpy2.callCount, 0
  equal callbackSpy.callCount, 0
  deepEqual handlerSpy.lastCallArguments, [@error]

test 'When wrapping multiple nested calls with errorHandler callback, nested errors not be ignored by higher level errors', 5, ->
  callbackSpy = createSpy()
  handlerSpy = createSpy()
  handlerSpy2 = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController::_customErrorHandler2 = handlerSpy2
  @TestController.catchError @CustomError, with: [@TestController::_customErrorHandler]
  @TestController.catchError @CustomError2, with: [@TestController::_customErrorHandler2]

  namespace = @

  @Model.load = (callback) ->
    callback(undefined, [{id: 1}], 'foo')
  @Model.load3 = (callback) ->
    callback(namespace.error, undefined)
  
  controller = new @TestController
  controller.index = ->
    controllerNamespace = @
    namespace.Model.load @errorHandler =>
      ok true
      namespace.Model.load2 @errorHandler callbackSpy
    namespace.Model.load3 @errorHandler callbackSpy
    @render false

  controller.dispatch('index')

  equal handlerSpy.callCount, 0
  equal handlerSpy2.callCount, 1
  equal callbackSpy.callCount, 0
  deepEqual handlerSpy2.lastCallArguments, [@error2]

test 'Calling handlerError directly with an error should result in the handlers being called', ->
  handlerSpy = createSpy()
  handlerSpy2 = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController.catchError @CustomError, with: [@TestController::_customErrorHandler]
  controller = new @TestController  

  equal controller.handleError(@error), true
  equal controller.handleError(@error2), false
  equal handlerSpy.callCount, 1
  equal handlerSpy2.callCount, 0
  deepEqual handlerSpy.lastCallArguments, [@error]
