helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module "Batman.View: data-render-if bindings"

asyncTest 'it should not render the inner nodes until the keypath is truthy', 4, ->
  context = proceed: false

  source = '<div data-renderif="proceed"><span data-bind="deferred">unrendered</span></div>'

  helpers.render source, context, (node, view) ->
    view.accessor 'deferred', spy = createSpy().whichReturns('inner value')

    ok !spy.called
    equal $('span', node).html(), 'unrendered'

    view.set('proceed', true)
    ok spy.called
    equal $('span', node).html(), 'inner value'

    QUnit.start()

asyncTest 'it should render the inner nodes in the same context as the node was in when it deferred rendering', 2, ->
  context =
    proceed: false
    foo: Batman
      foo: "bar"

  source = '<div data-context-alias="foo"><div data-renderif="proceed"><span data-bind="alias.foo">unrendered</span></div></div>'

  helpers.render source, context, (node, view) ->
    equal $('span', node).html(), 'unrendered'
    view.set('proceed', true)
    equal $('span', node).html(), 'bar'
    QUnit.start()

asyncTest 'it should continue rendering on the node it stopped rendering', 2, ->
  context = proceed: false, foo: "bar"

  source = '<div data-bind="foo" data-renderif="proceed" >unrendered</div>'

  helpers.render source, context, (node, view) ->
    equal node.html(), 'unrendered'
    view.set('proceed', true)
    equal node.html(), 'bar'
    QUnit.start()

asyncTest 'it should only render the inner nodes once', 3, ->
  context = proceed: false, deferred: spy = createSpy().whichReturns('inner value')

  source = '<div data-renderif="proceed"><span data-bind="deferred">unrendered</span></div>'
  class InstrumentedRenderer extends Batman.BindingParser
    @instanceCount: 0
    constructor: ->
      InstrumentedRenderer.instanceCount++
      super

  oldRenderer = Batman.BindingParser
  Batman.BindingParser = InstrumentedRenderer

  helpers.render source, context, (node, view) ->
    equal InstrumentedRenderer.instanceCount, 1
    view.set('proceed', true)
    equal InstrumentedRenderer.instanceCount, 2

    view.set('proceed', false)
    view.set('proceed', true)
    equal InstrumentedRenderer.instanceCount, 2
    Batman.BindingParser = oldRenderer

    QUnit.start()
