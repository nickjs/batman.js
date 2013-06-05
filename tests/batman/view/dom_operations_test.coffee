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
    newElement.appendChild(context.TestView.instance.get('node'))
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
    newElement.appendChild(context.OuterView.instance.get('node'))
    equal innerAppearSpy.callCount, 2

    equal $(newElement).find('span').html(), "foo"
    view.set('bar', 'baz')
    equal $(newElement).find('span').html(), "baz"
    QUnit.start()
