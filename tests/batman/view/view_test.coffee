helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

count = 0
oldRequest = Batman.Request

class MockRequest extends MockClass
  @chainedCallback 'success'
  @chainedCallback 'error'

QUnit.module 'Batman.View',
  setup: ->
    MockRequest.reset()
    Batman.Request = MockRequest

    @options = source: "test_path#{++count}"
    @superview = new Batman.View(node: document.createElement('div'))
    @view = new Batman.View(@options)

  teardown: ->
    Batman.Request = oldRequest

test 'should pull in the source for a view from a path', ->
  @superview.subviews.add(@view)
  equal MockRequest.lastConstructorArguments[0].url, "/assets/batman/html/#{@options.source}.html"

test 'should update its node with the contents of its view', ->
  @superview.subviews.add(@view)
  MockRequest.lastInstance.fireSuccess('view contents')
  equal @view.get('node').innerHTML, 'view contents'

test 'should not add its node property as a source to an enclosing accessor', ->
  accessible = new Batman.Accessible -> new Batman.View()
  view = accessible.get()
  view.set('node', {})
  newView = accessible.get()
  equal newView, view

test 'should update a new, set node with the contents of its view after the source loads', ->
  div = document.createElement('div')
  @superview.get('node').appendChild(div)
  @view.parentNode = div
  @superview.subviews.add(@view)
  MockRequest.lastInstance.fireSuccess('view contents')
  equal div.children[0].innerHTML, 'view contents'

asyncTest 'should fire the ready event once its contents have been loaded', 1, ->
  @view.on 'ready', observer = createSpy()
  @superview.subviews.add(@view)

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
  equal Batman.View.store.get('foo'), 'foo!'

test ".store should pull absolutely path'd data-defineview'd views from the DOM", ->
  $('#qunit-fixture').html  """
    <div data-defineview="/bar">bar!</div>
  """
  equal Batman.View.store.get('bar'), 'bar!'
  equal Batman.View.store.get('/bar'), 'bar!'

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
  @superview.subviews.add(@view)
  equal MockRequest.lastInstance, false

QUnit.module 'Batman.View isInDOM',
  setup: ->
    @options = html: "predetermined contents"
    @superview = new Batman.View(node: document.createElement('div'))
    @view = new Batman.View(@options)
    @superview.initializeBindings()

  teardown: ->
    Batman.DOM.Yield.reset()

test 'should report isInDOM correctly as false when without node', ->
  equal @view.isInDOM, false

asyncTest 'should report isInDOM correctly as false when with node but not in the dom', ->
  node = document.createElement('div')
  @view.set('node', node)
  @superview.subviews.add(@view)
  equal @view.isInDOM, false
  delay =>
    equal @view.isInDOM, false

asyncTest 'should report isInDOM correctly as true when a yielded node is in the dom', ->
  source = '''
  <div data-contentfor="baz">chunky bacon</div>
  <div data-yield="baz" id="test">erased</div>
  '''

  node = helpers.render source, {}, (node, view) ->
    ok view.isInDOM
    QUnit.start()

asyncTest 'should report isInDOM correctly as true when only one of many yielded nodes is in the dom', ->
  source = '''
  <div data-contentfor="bar">chunky bacon</div>
  <div data-yield="bar">erased</div>
  <div data-contentfor="baz">chunky bacon</div>
  <div data-contentfor="qux">chunky bacon</div>
  '''

  helpers.render source, {}, (node, view) ->
    ok view.isInDOM
    QUnit.start()

test 'should report isInDOM correctly as false when none of many yielded nodes is in the dom', ->
  html = '''
  <div data-contentfor="bar">chunky bacon</div>
  <div data-contentfor="baz">chunky bacon</div>
  <div data-contentfor="qux">chunky bacon</div>
  '''

  view = new Batman.View(html: html)
  view.initializeBindings()
  ok !view.isInDOM

# FIXME
# asyncTest 'die should call die on properties', 1, ->
#   source = '''
#   <div data-bind="foo.bar"></div>
#   <div data-bind="foo.baz"></div>
#   '''

#   helpers.render source, {}, (node, view) ->
#     spy = createSpy()
#     properties = view._batman.properties.toArray()
#     view.property(property).die = spy for property in properties
#     view.die()
#     equal spy.callCount, properties.length
#     QUnit.start()

# asyncTest 'die should forget observers and fire destroy', 2, ->
#   source = '''
#   <div data-bind="foo.bar"></div>
#   <div data-bind="foo.baz"></div>
#   '''
#   node = helpers.render source, {}, (node, view) ->
#     view.fire = fireSpy = createSpy()
#     view.forget = forgetSpy = createSpy()
#     view.die()
#     ok fireSpy.called
#     ok forgetSpy.called
#     QUnit.start()
