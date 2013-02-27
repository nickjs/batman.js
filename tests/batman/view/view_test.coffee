helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

oldRequest = Batman.Request
class MockRequest extends MockClass
  @chainedCallback 'success'
  @chainedCallback 'error'
count = 0

QUnit.module 'Batman.View'
  setup: ->
    Batman.View.store = new Batman.HTMLStore
    MockRequest.reset()
    @options =
      source: "test_path#{++count}"

    Batman.Request = MockRequest
    @view = new Batman.View(@options) # create a view which uses the MockRequest internally

  teardown: ->
    Batman.Request = oldRequest

test 'should pull in the source for a view from a path', 1, ->
  equal MockRequest.lastConstructorArguments[0].url, "/assets/batman/html/#{@options.source}.html"

test 'should update its node with the contents of its view', 1, ->
  MockRequest.lastInstance.fireSuccess('view contents')
  equal @view.get('node').innerHTML, 'view contents'

test 'should not add its node property as a source to an enclosing accessor', 1, ->
  class TestView extends Batman.View
    render: spy = createSpy().whichReturns(true)

  accessible = new Batman.Accessible -> new TestView()
  view = accessible.get()
  view.set('node', {})
  newView = accessible.get()
  equal newView, view

test 'should update a new, set node with the contents of its view after the source loads', 1, ->
  node = document.createElement('div')
  @view.set('node', node)
  MockRequest.lastInstance.fireSuccess('view contents')
  equal node.innerHTML, 'view contents'

test 'should update a new, set node node with the contents of its view if the node is set after the source loads', 1, ->
  node = document.createElement('div')
  MockRequest.lastInstance.fireSuccess('view contents')
  @view.set('node', node)
  equal node.innerHTML, 'view contents'

test "should not render if the node is set but the html hasn't come back", 1, ->
  node = document.createElement('div')
  @view.render = createSpy()
  @view.set('node', node)
  ok !@view.render.called

test "should render if the node is set and no html needs to come back", 1, ->
  @view = new Batman.View(source: undefined, html: undefined)
  @view.render = createSpy()
  node = document.createElement('div')
  @view.set('node', node)
  ok @view.render.called

asyncTest 'should fire the ready event once its contents have been loaded', 1, ->
  @view.on 'ready', observer = createSpy()

  MockRequest.lastInstance.fireSuccess('view contents')
  delay =>
    ok observer.called

asyncTest 'should call the ready function once its contents have been loaded', 1, ->
  @view.ready = observer = createSpy()

  MockRequest.lastInstance.fireSuccess('view contents')
  delay =>
    ok observer.called

asyncTest '.store should allow prefetching of view sources', 2, ->
  Batman.View.store.prefetch('view')
  equal MockRequest.lastConstructorArguments[0].url, "/assets/batman/html/view.html"
  delay =>
    MockRequest.lastInstance.fireSuccess('prefetched contents')
    view = new Batman.View({source: 'view'})
    equal view.get('html'), 'prefetched contents'

test ".store should pull unrendered data-defineview'd views from the DOM", ->
  $('#qunit-fixture').html  """
    <div data-defineview="foo">foo!</div>
  """

  equal MockRequest.instances.length, 1
  equal Batman.View.store.get('foo'), 'foo!'
  equal MockRequest.instances.length, 1

test ".store should pull absolutely path'd data-defineview'd views from the DOM", ->
  $('#qunit-fixture').html  """
    <div data-defineview="/bar">bar!</div>
  """

  equal MockRequest.instances.length, 1
  equal Batman.View.store.get('bar'), 'bar!'
  equal Batman.View.store.get('/bar'), 'bar!'
  equal MockRequest.instances.length, 1

test ".store should raise if remote fetching is disabled", ->
  Batman.config.fetchRemoteHTML = false
  QUnit.raises ->
    Batman.View.store.get('remote')
  Batman.config.fetchRemoteHTML = true

test 'should not autogenerate a node if the node property is false', 1, ->
  MockRequest.reset()

  class SpecialView extends Batman.View
    node: false

  @view = new SpecialView(@options)
  equal MockRequest.lastInstance, false

asyncTest 'should render a given node after not autogenerating one if the node property is false', 4, ->
  class SpecialView extends Batman.View
    node: false
    html: '<span data-bind="foo"></span>'

  renderSpy = spyOn SpecialView.prototype, 'render'

  @view = new SpecialView context: {foo: 'bar'}
  delay =>
    equal renderSpy.callCount, 0
    equal @view.get('node'), false
    @view.set 'node', document.createElement('div')
    delay =>
      equal renderSpy.callCount, 1
      equal @view.get('node').childNodes[0].innerHTML, 'bar'

QUnit.module 'Batman.View isInDOM'
  setup: ->
    @options =
      html: "predetermined contents"

    @view = new Batman.View(@options)
  teardown: ->
    Batman.DOM.Yield.reset()

test 'should report isInDOM correctly as false when without node', ->
  equal @view.isInDOM(), false

asyncTest 'should report isInDOM correctly as false when with node but not in the dom', ->
  node = document.createElement('div')
  @view.set('node', node)
  equal @view.isInDOM(), false
  delay =>
    equal @view.isInDOM(), false

asyncTest 'should report isInDOM correctly as true when it\'s node is in the dom', ->
  node = $('<div/>')
  @view.set('node', node[0])
  @view.on 'ready', =>
    node.appendTo($('body'))
    ok @view.isInDOM()
    node.remove()
    equal @view.isInDOM(), false
    QUnit.start()

asyncTest 'should report isInDOM correctly as true when a yielded node is in the dom', ->
  source = '''
  <div data-contentfor="baz">chunky bacon</div>
  <div data-yield="baz" id="test">erased</div>
  '''
  node = helpers.render source, {}, (node, view) ->
    ok view.isInDOM()
    QUnit.start()

asyncTest 'should report isInDOM correctly as true when only one of many yielded nodes is in the dom', ->
  source = '''
  <div data-contentfor="bar">chunky bacon</div>
  <div data-yield="bar">erased</div>
  <div data-contentfor="baz">chunky bacon</div>
  <div data-contentfor="qux">chunky bacon</div>
  '''
  node = helpers.render source, {}, (node, view) ->
    ok view.isInDOM()
    QUnit.start()

asyncTest 'should report isInDOM correctly as false when none of many yielded nodes is in the dom', ->
  source = '''
  <div data-contentfor="bar">chunky bacon</div>
  <div data-contentfor="baz">chunky bacon</div>
  <div data-contentfor="qux">chunky bacon</div>
  '''
  node = helpers.render source, {}, (node, view) ->
    equal view.isInDOM(), false
    QUnit.start()

asyncTest 'die should call die on properties', 1, ->
  source = '''
  <div data-bind="foo.bar"></div>
  <div data-bind="foo.baz"></div>
  '''
  node = helpers.render source, {}, (node, view) ->
    spy = createSpy()
    properties = view._batman.properties.toArray()
    view.property(property).die = spy for property in properties
    view.die()
    equal spy.callCount, properties.length
    QUnit.start()

asyncTest 'die should forget observers and fire destroy', 2, ->
  source = '''
  <div data-bind="foo.bar"></div>
  <div data-bind="foo.baz"></div>
  '''
  node = helpers.render source, {}, (node, view) ->
    view.fire = fireSpy = createSpy()
    view.forget = forgetSpy = createSpy()
    view.die()
    ok fireSpy.called
    ok forgetSpy.called
    QUnit.start()
