helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module "Batman.DOM helpers",
  setup: ->
    class @TestView extends Batman.View
      constructor: ->
        @constructor.instance = @
        super

    @context = Batman
      OuterView: class OuterView extends @TestView
      InnerView: class InnerView extends @TestView

    @simpleSource = '<div class="outer" data-view="OuterView"><div><p class="inner" data-view="InnerView"></p></div></div>'
  teardown: ->
    Batman.DOM.Yield.reset()

asyncTest "setInnerHTML fires beforeDisappear and disappear events on views about to be removed", 4, ->
  helpers.render @simpleSource, false, @context, (node) =>
    @context.OuterView.instance.on 'beforeDisappear', -> ok @get('node').parentNode
    @context.OuterView.instance.on 'disappear',       -> ok !@get('node').parentNode
    @context.InnerView.instance.on 'beforeDisappear', -> ok @get('node').parentNode
    @context.InnerView.instance.on 'disappear',       -> ok @get('node').parentNode

    Batman.DOM.setInnerHTML(node, "")
    QUnit.start()

test "addEventListener and removeEventListener store and remove callbacks using Batman.data", ->
  div = document.createElement 'div'
  f = ->

  Batman.DOM.addEventListener div, 'click', f
  listeners = Batman._data div, 'listeners'
  ok ~listeners.click.indexOf f

  Batman.DOM.removeEventListener div, 'click', f
  listeners = Batman._data div, 'listeners'
  ok !~listeners.click.indexOf f

test "textContent should return textContent", ->
  node = $("<a>test</a>")[0]
  equal Batman.DOM.textContent(node), 'test'

asyncTest "destroyNode: destroys yielded childNodes when their parents are destroyed", 2, ->
  source = """
    <div class="bar" data-yield="bar"></div>
    <div class="notcached" data-view="OuterView">
      <div data-contentfor="bar">
        <div data-view="InnerView">
          uncached content
        </div>
      </div>
    </div>
  """
  helpers.render source, false, @context, (node) =>
    @context.OuterView.instance.on 'destroy', -> ok true
    @context.InnerView.instance.on  'destroy', -> ok true
    Batman.DOM.destroyNode($('.notcached', node)[0])

    equal $('.bar', node).html(), ""

    QUnit.start()

asyncTest "destroyNode: destroys nodes inside a yield when the yield is destroyed", 1, ->
  source = """
    <div class="bar" data-yield="bar"></div>
    <div class="notcached" data-view="OuterView">
      <div data-contentfor="bar">
        <div data-view="InnerView">
          uncached content
        </div>
      </div>
    </div>
  """

  helpers.render source, false, @context, (node) =>
    @context.InnerView.instance.on 'destroy', -> ok true
    Batman.DOM.destroyNode($('.bar', node)[0])
    QUnit.start()

asyncTest "destroyNode: bindings are kept in Batman.data and destroyed when the node is removed", 6, ->
  context = {bar: true, foo: (spy = createSpy -> @get('bar'))}
  helpers.render '<div data-addclass-foo="foo"><div data-addclass-foo="foo"></div></div>', context, (node, view) ->
    ok spy.called

    parent = node[0]
    child = parent.childNodes[0]
    for node in [child, parent]
      Batman.DOM.destroyNode node
      deepEqual Batman._data(node), {}

    view.set('bar', false)
    equal spy.callCount, 1
    QUnit.start()

asyncTest "destroyNode: iterators are kept in Batman.data and destroyed when the parent node is removed", 5, ->
  set = null
  context = {bar: 'baz', foo:(setSpy = createSpy -> set = new Batman.Set @get('bar'), 'qux')}
  helpers.render '<div id="parent"><div data-foreach-x="foo" data-bind="x"></div></div>', context, (node, view) ->
    equal setSpy.callCount, 1  # Cached, so only called once

    parent = node[0]
    toArraySpy = spyOn(set, 'toArray')

    Batman.DOM.destroy(parent)
    deepEqual Batman._data(parent), {}

    view.set('bar', false)
    equal setSpy.callCount, 1

    equal toArraySpy.callCount, 0
    set.fire('change')
    equal toArraySpy.callCount, 0
    QUnit.start()

asyncTest "destroyNode: Batman.DOM.Style objects are kept in Batman.data and destroyed when their node is removed", ->
  styles = null
  context = {styles: new Batman.Hash(color: 'green'), css: (setSpy = createSpy -> styles = @styles)}

  helpers.render '<div data-bind-style="css"></div>', context, (node, view) ->
    equal setSpy.callCount, 1  # Cached, so only called once

    node = node[0]
    itemsAddedSpy = spyOn(context.get('styles'), 'itemsWereAdded')

    Batman.DOM.destroyNode(node)
    deepEqual Batman._data(node), {}

    view.set('styles', false)
    equal setSpy.callCount, 1

    equal itemsAddedSpy.callCount, 0
    styles.fire('itemsWereAdded')
    equal itemsAddedSpy.callCount, 0
    QUnit.start()

asyncTest "destroyNode: listeners are kept in Batman.data and destroyed when the node is removed", 8, ->
  context = {foo: ->}

  helpers.render '<div data-event-click="foo"><div data-event-click="foo"></div></div>', context, (node, view) ->
    parent = node[0]
    child = parent.childNodes[0]
    for n in [child, parent]
      listeners = Batman._data n, 'listeners'
      ok listeners.click.length > 0

      if Batman.DOM.hasAddEventListener
        spy = spyOn n, 'removeEventListener'
      else
        # Spoof detachEvent because typeof detachEvent is 'object' in IE8, and
        # spies break because detachEvent.call blows up
        n.detachEvent = ->
        spy = spyOn n, 'detachEvent'

      Batman.DOM.destroyNode n

      ok spy.called
      deepEqual Batman.data(n), {}
      deepEqual Batman._data(n), {}

    QUnit.start()

asyncTest "destroyNode: nodes with views are not unbound if they are cached", ->
  context =
    bar: "foo"
    TestView: class TestView extends Batman.View
      cached: true

  helpers.render '<div data-view="TestView"><span data-bind="bar"></span></div>', context, (node, view) ->
    equal node.find('span').html(), "foo"
    Batman.DOM.destroyNode node[0]
    view.set('bar', 'baz')
    equal node.find('span').html(), "baz"
    QUnit.start()

asyncTest "destroyNode: cached view can be reinserted", ->
  context =
    bar: "foo"
    TestView: @TestView

  helpers.render '<div data-view="TestView"><span data-bind="bar"></span></div>', context, (node, view) ->
    equal node.find('span').html(), "foo"
    Batman.DOM.destroyNode(node[0])

    newElement = $('<div/>')[0]
    Batman.DOM.appendChild newElement, context.TestView.instance.get('node')
    equal $(newElement).find('span').html(), "foo"
    view.set('bar', 'baz')
    equal $(newElement).find('span').html(), "baz"
    QUnit.start()

asyncTest "destroyNode: cached views with inner views can be reinserted", ->
  innerAppearSpy = createSpy()
  innerDisappearSpy = createSpy()

  context =
    bar: "foo"
    OuterView: class OuterView extends @TestView
      cached: true
    InnerView: class InnerView extends @TestView
      constructor: ->
        super
        @on 'appear', innerAppearSpy
        @on 'disappear', innerDisappearSpy

  helpers.render '<div data-view="OuterView"><div data-view="InnerView"><span data-bind="bar"></span></div></div>', context, (node, view) ->
    equal node.find('span').html(), "foo"
    equal innerAppearSpy.callCount, 1
    equal innerDisappearSpy.callCount, 0

    Batman.DOM.destroyNode(node[0])
    equal innerDisappearSpy.callCount, 1

    newElement = $('<div/>')[0]
    Batman.DOM.appendChild newElement, context.OuterView.instance.get('node')
    equal innerAppearSpy.callCount, 2

    equal $(newElement).find('span').html(), "foo"
    view.set('bar', 'baz')
    equal $(newElement).find('span').html(), "baz"
    QUnit.start()

asyncTest "bindings added underneath other bindings notify their parents", ->
  context = Batman
    foo: "foo"
    bar: "bar"

  class TestBinding extends Batman.DOM.AbstractBinding
    @instances = []
    constructor: ->
      @childBindingAdded = createSpy()
      super
      @constructor.instances.push @

  Batman.DOM.readers.test = -> new TestBinding(arguments...)
  source = '''
    <div data-test="true">
      <div data-test="true">
        <p data-bind="foo"></p>
        <p data-bind="bar"></p>
      </div>
    </div>
  '''

  helpers.render source, context, (node, view) ->
    equal TestBinding.instances.length, 2
    equal TestBinding.instances[0].childBindingAdded.callCount, 3
    calls = TestBinding.instances[0].childBindingAdded.calls
    ok calls[0].arguments[0] instanceof TestBinding
    ok calls[1].arguments[0] instanceof Batman.DOM.AbstractBinding
    ok calls[1].arguments[0].get('filteredValue'), 'foo'
    ok calls[2].arguments[0] instanceof Batman.DOM.AbstractBinding
    ok calls[2].arguments[0].get('filteredValue'), 'bar'

    equal TestBinding.instances[1].childBindingAdded.callCount, 2
    calls = TestBinding.instances[1].childBindingAdded.calls
    ok calls[0].arguments[0] instanceof Batman.DOM.AbstractBinding
    ok calls[0].arguments[0].get('filteredValue'), 'foo'
    ok calls[1].arguments[0] instanceof Batman.DOM.AbstractBinding
    ok calls[1].arguments[0].get('filteredValue'), 'bar'
    QUnit.start()
