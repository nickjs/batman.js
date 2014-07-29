helpers = window.viewHelpers

oldApp = Batman.currentApp
oldHTMLStore = Batman.View.store
oldNavigator = Batman.navigator

QUnit.module 'Batman.Controller',
  setup: ->
    class TestController extends Batman.Controller
      show: ->

    Batman.currentApp = Batman(layout: new Batman.View(node: document.createElement('div')))
    Batman.View.store.set('foo', "<div>show</div>")
    Batman.View.store.set('test/show', "<div>show</div>")
    Batman.View.store.set('products/show', "<div>show</div>")
    Batman.View.store.set('admin/products/show', "<div>show</div>")

    Batman.config.cacheViews = true
    @controller = new TestController
    @controller.renderCache.reset()
    Batman.DOM.Yield.reset()

  teardown: ->
    Batman.config.cacheViews = false
    Batman.currentApp = oldApp
    Batman.navigator = oldNavigator
    Batman.View.store = oldHTMLStore

test 'get(\'routingKey\') should use the prototype level routingKey property', ->
  class ProductsController extends Batman.Controller
    routingKey: 'products'

  equal (new ProductsController).get('routingKey'), 'products'

test 'it should render a Batman.View if `view` isn\'t given in the options to render', ->
  @controller.dispatch('show')
  equal Batman.currentApp.layout.subviews.length, 1

  newView = Batman.currentApp.layout.subviews.get('first')
  ok newView.isBound

test 'it should cache the rendered Batman.View if `view` isn\'t given in the options to render', ->
  @controller.dispatch('show')
  view = Batman.currentApp.layout.subviews.get('first')

  @controller.dispatch('show')
  equal Batman.currentApp.layout.subviews.get('first')._batmanID(), view._batmanID()

test 'it should render a Batman.View subclass with the ControllerAction name on the current app if it exists', ->
  @controller.dispatch 'show'
  view = Batman.currentApp.layout.subviews.get('first')
  equal view.source, 'test/show'

test 'it should render a Batman.View subclass with the ControllerAction name if the routing key is nested', ->
  @controller.set 'routingKey', 'admin/products'
  @controller.dispatch 'show'
  view = Batman.currentApp.layout.subviews.get('first')
  equal view.source, 'admin/products/show'

test 'it should cache the rendered Batman.Views if rendered from different action', ->
  @controller.actionA = ->
    @render source: 'foo'
  @controller.actionB = ->
    @render source: 'foo'

  @controller.dispatch 'actionA'
  view = Batman.currentApp.layout.subviews.get('first')

  @controller.dispatch 'actionB'
  equal Batman.currentApp.layout.subviews.get('first')._batmanID(), view._batmanID()

asyncTest 'it should cache the rendered Batman.Views if rendered from different actions into different yields', ->
  mainContainer = $('<div>')[0]
  detailContainer = $('<div>')[0]
  Batman.DOM.Yield.withName('main').set('containerNode', mainContainer)
  Batman.DOM.Yield.withName('detail').set('containerNode', detailContainer)

  @controller.index = ->
    @render(html: 'foo', into: 'main', source: 'a')

  @controller.show = ->
    @index()
    @render(html: 'bar', into: 'detail', source: 'b')

  @controller.dispatch 'index'
  delay =>
    mainView = Batman._data(mainContainer.childNodes[0], 'view')
    @controller.dispatch 'show'
    delay ->
      equal Batman._data(mainContainer.childNodes[0], 'view'), mainView, "The same view was used in the second dispatch"

test 'it should render views if given in the options', ->
  view = new Batman.View
  @controller.render({view})
  equal Batman.currentApp.layout.subviews.get('first'), view

test 'it should load the HTML from the default location', ->
  class TestShowView extends Batman.View

  Batman.currentApp["TestShowView"] = TestShowView

  @controller.dispatch('show')
  equal @controller.currentView.source, 'test/show'

test 'it should load the HTML from the override location on the view prototype', ->
  class TestShowView extends Batman.View
    source: 'override/source'
  Batman.currentApp["TestShowView"] = TestShowView

  @controller.dispatch('show')
  equal @controller.currentView.source, 'override/source'

test 'it should allow setting the default render destination yield', ->
  view = new Batman.View
  @controller.defaultRenderYield = 'sidebar'
  @controller.render({view})

  equal Batman.currentApp.layout.subviews.get('first'), view
  equal Batman.DOM.Yield.withName('sidebar').get('contentView'), view

test 'dispatching routes without any actions calls render', ->
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

test 'redirecting using @redirect() in an action prevents implicit render', ->
  Batman.navigator = {redirect: createSpy()}
  @controller.test = -> @redirect '/'
  @controller.dispatch 'test'
  equal Batman.currentApp.layout.subviews.length, 0
  ok Batman.navigator.redirect.called

test 'redirecting using Batman.redirect in an action prevents implicit render', ->
  Batman.navigator = {redirect: createSpy()}
  @controller.test = -> Batman.redirect '/'
  @controller.dispatch 'test'
  equal Batman.currentApp.layout.subviews.length, 0
  ok Batman.navigator.redirect.called

test '@redirect-ing after a dispatch fires no warnings', ->
  Batman.navigator = {redirect: createSpy()}
  @controller.test = -> @render false
  @controller.dispatch 'test'
  @controller.redirect '/'
  ok Batman.navigator.redirect.called

test 'redirecting with an object should add the current controller if not present', ->
  Batman.navigator = {redirect: createSpy()}
  @controller.redirect(action: 'show')
  ok Batman.navigator.redirect.lastCallArguments = [{action: "show", controller: "test_controller"}]

test 'filters specifying no restrictions should be called on all actions', ->
  spy = createSpy()
  class FilterController extends Batman.Controller
    @beforeAction spy

    index: -> @render(false)
    show: -> @render(false)

  controller = new FilterController

  controller.dispatch('index')
  equal spy.callCount, 1

  controller.dispatch('show')
  equal spy.callCount, 2

test 'filters specified with strings should work the same way', ->
  spy = createSpy()
  class FilterController extends Batman.Controller
    @beforeAction 'callSpy'

    index: -> @render(false)
    show: -> @render(false)

    callSpy: ->
      spy()

  controller = new FilterController

  controller.dispatch('index')
  equal spy.callCount, 1

  controller.dispatch('show')
  equal spy.callCount, 2

test 'filters specified on instances should only work on that instance', ->
  spy = createSpy()
  class FilterController extends Batman.Controller
    index: -> @render(false)

  controller = new FilterController
  controller.beforeAction(spy)
  controller.dispatch('index')
  equal(spy.callCount, 1)

test 'filters specifying only should only be called on those actions', ->
  spy = createSpy()

  class FilterController extends Batman.Controller
    @beforeAction only: 'withBefore', spy

    withBefore: -> @render false
    all: -> @render false

  controller = new FilterController

  controller.dispatch('withBefore')
  equal spy.callCount, 1

  controller.dispatch('all')
  equal spy.callCount, 1

test 'filters specified with strings and only (in either order) should only be called on those actions', ->
  firstSpy = createSpy()
  secondSpy = createSpy()

  class FilterController extends Batman.Controller
    @beforeAction only: 'first', 'callFirstSpy'
    @beforeAction 'callSecondSpy', only: 'second'

    first: -> @render(false)
    second: -> @render(false)

    callFirstSpy: ->
      firstSpy()

    callSecondSpy: ->
      secondSpy()

  controller = new FilterController

  controller.dispatch('first')
  equal firstSpy.callCount, 1

  controller.dispatch('second')
  equal secondSpy.callCount, 1

test 'filters specifying except should not be called on those actions', ->
  spy = createSpy()
  class FilterController extends Batman.Controller
    @beforeAction {except: 'index'}, spy

    show: -> @render false
    index: -> @render false

  controller = new FilterController

  controller.dispatch 'show'
  equal spy.callCount, 1
  controller.dispatch 'index'
  equal spy.callCount, 1

test 'filters specifying options in arrays should apply to all/none of those options', ->
  spy = createSpy()
  class FilterController extends Batman.Controller
    @beforeAction {except: ['index', 'edit']}, spy

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

test 'redirect() in beforeFilter halts chain and does not call action or render', ->
  beforeSpy1 = createSpy()
  beforeSpy2 = createSpy()
  renderSpy = createSpy()
  afterSpy = createSpy()

  class FilterController extends Batman.Controller
    @beforeAction beforeSpy1
    @beforeAction -> @redirect('/')
    @beforeAction beforeSpy2
    @afterAction afterSpy

    render: renderSpy
    index: -> @render(false)

  controller = new FilterController
  controller.dispatch('index')
  equal beforeSpy1.callCount, 1
  equal beforeSpy2.callCount, 0
  equal renderSpy.callCount, 0
  equal afterSpy.callCount, 0

test 'actions executed by other actions implicitly render', ->
  @controller.test = ->
    @render false
    @executeAction 'show'

  @controller.dispatch 'test'

  view = Batman.currentApp.layout.subviews.get('first')
  equal view.source, 'test/show', "The action is correctly different inside the inner execution"

test 'actions executed by other actions have their filters run', ->
  beforeSpy = createSpy()
  afterSpy = createSpy()

  class TestController extends Batman.Controller
    @beforeAction {only: 'show'}, beforeSpy
    @afterAction {only: 'show'}, afterSpy

    show: ->
      @render(false)

    test: ->
      @render(false)
      @executeAction('show')

  @controller = new TestController
  @controller.dispatch('test')

  ok beforeSpy.called
  ok afterSpy.called

test 'beforeActions and afterActions are inherited when subclassing controllers', ->
  beforeSpy1 = createSpy()
  beforeSpy2 = createSpy()
  afterSpy1 = createSpy()
  afterSpy2 = createSpy()

  class TestParentController extends Batman.Controller
    @beforeAction beforeSpy1
    @beforeAction {only: 'show'}, beforeSpy2
    @afterAction afterSpy1
    @afterAction {only: 'show'}, afterSpy2

    show: -> @render false

  beforeSpy3 = createSpy()
  beforeSpy4 = createSpy()
  afterSpy3 = createSpy()
  afterSpy4 = createSpy()

  class TestChildController extends TestParentController
    @beforeAction beforeSpy3
    @beforeAction {only: 'show'}, beforeSpy4
    @afterAction afterSpy3
    @afterAction {only: 'show'}, afterSpy4

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

test 'afterActions should only fire after renders are complete', ->
  afterSpy = createSpy()
  view = new Batman.View

  class TestController extends Batman.Controller
    @afterAction {only: 'show'}, afterSpy
    show: -> @render(view: view)

  @controller = new TestController
  view.prevent('viewDidAppear')

  @controller.dispatch('show')
  ok !afterSpy.called
  view.allowAndFire('viewDidAppear')
  ok afterSpy.called

test 'afterActions on outer actions should fire after afterActions on inner actions', ->
  order = []
  class TestController extends Batman.Controller
    @afterAction {only: 'show'}, -> order.push 1
    @afterAction {only: 'test'}, -> order.push 2
    show: ->
      @render(false)

    test: ->
      @render(false)
      @executeAction('show')

  @controller = new TestController
  @controller.dispatch('test')
  deepEqual order, [1, 2]

test 'afterActions on outer actions should only fire after inner renders are complete', ->
  afterSpy = createSpy()
  view = new Batman.View

  class TestController extends Batman.Controller
    @afterAction {only: 'test'}, afterSpy
    show: -> @render(view: view)
    test: ->
      @render false
      @executeAction 'show'

  @controller = new TestController
  view.prevent('viewDidAppear')

  @controller.dispatch('test')
  ok !afterSpy.called
  view.allowAndFire('viewDidAppear')
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

test 'integer-ish params are coerced to integers', ->
  @controller.show = createSpy()
  @controller.dispatch 'show', {id: "215", name: "Back to the Future 2"}
  params = @controller.show.lastCallArguments[0]
  strictEqual params.id, 215
  equal params.name, 'Back to the Future 2'

test 'integer coercion can be disabled', ->
  @controller.coerceIntegerParams = false
  @controller.show = createSpy()
  @controller.dispatch 'show', {id: "215", name: "Back to the Future 2"}
  params = @controller.show.lastCallArguments[0]
  strictEqual params.id, '215'
  equal params.name, 'Back to the Future 2'

QUnit.module 'Batman.Controller error handling',
  setup: ->
    class @CustomError extends Batman.Object
    class @CustomError2 extends Batman.Object

    @error = error = new @CustomError
    @error2 = error2 = new @CustomError2

    class @Model extends Batman.Object
      @load: (callback) ->
        callback?(error, undefined)
        Promise.reject(error)
      @load2: (callback) ->
        callback?(error2, undefined)
        Promise.reject(error2)

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

test 'when wrapping a call with the errorHandler callback, any exception tracked with catchError will be handled by multiple handlers', ->
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

asyncTest '@handleError can be used in Promise::catch', 5,  ->
  callbackSpy = createSpy()
  handlerSpy = createSpy()
  handlerSpy2 = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController::_customErrorHandler2 = handlerSpy2
  @TestController.catchError @CustomError, with: [@TestController::_customErrorHandler, @TestController::_customErrorHandler2]

  makeAssertions = =>
    equal callbackSpy.callCount, 0
    equal handlerSpy.callCount, 1
    equal handlerSpy2.callCount, 1
    deepEqual handlerSpy.lastCallArguments, [@error]
    deepEqual handlerSpy2.lastCallArguments, [@error]

  namespace = @
  controller = new @TestController
  controller.index = ->
    namespace.Model.load()
      .then(callbackSpy)
      .catch(@handleError)
      .then(makeAssertions)
      .then(QUnit.start())
    @render false

  controller.dispatch('index')

test 'when wrapping a call with the errorHandler callback, any exception that is not tracked with specific catchError will be re-thrown', ->
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

  throws ->
    controller.dispatch('index')
  , Error

  equal callbackSpy.callCount, 0
  equal handlerSpy.callCount, 0

test 'when wrapping a call with the errorHandler callback, no exception passes result to callback', ->
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

test 'subclass errors registered with superclass catchError cause the errorHandler callback to fire', ->
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

test 'When wrapping a call with the errorHandler callback, parent class handlers are also called', ->
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

test 'When wrapping multiple calls with errorHandler callback, any successive calls to the errorHandler should be ignored if an error occured on the current frame', ->
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

test 'When wrapping multiple nested calls with errorHandler callback, nested errors should not be fired if parent errored', ->
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

test 'When wrapping multiple nested calls with errorHandler callback, nested errors not be ignored by higher level errors', ->
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

test "catchError's with option should accept a string with the name of the handler", ->

  handlerSpy = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController.catchError @CustomError, with: '_customErrorHandler'

  namespace = @
  controller = new @TestController
  controller.index = ->
    namespace.Model.load @errorHandler ->
    @render false
  controller.dispatch('index')

  equal handlerSpy.callCount, 1

test "catchError's with option should accept an array of strings with the names of the handlers", ->

  handlerSpy = createSpy()
  handlerSpy2 = createSpy()

  @TestController::_customErrorHandler = handlerSpy
  @TestController::_customError2Handler = handlerSpy2

  @TestController.catchError @CustomError, with: ['_customErrorHandler', '_customError2Handler']

  namespace = @
  controller = new @TestController
  controller.index = ->
    namespace.Model.load @errorHandler ->
    @render false
  controller.dispatch('index')

  equal handlerSpy.callCount, 1
  equal handlerSpy2.callCount, 1