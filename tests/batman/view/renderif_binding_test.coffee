helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module "Batman.View: data-render-if bindings",
asyncTest 'it should not render the inner nodes until the keypath is truthy', 4, ->
  context = Batman
    proceed: false
  context.accessor 'deferred', spy = createSpy().whichReturns('inner value')

  source = '<div data-renderif="proceed"><span data-bind="deferred">unrendered</span></div>'

  helpers.render source, context, (node) ->
    ok !spy.called
    context.set('proceed', true)
    equal $('span', node).html(), 'unrendered'
    delay ->
      ok spy.called
      equal $('span', node).html(), 'inner value'

asyncTest 'it should render the inner nodes in the same context as the node was in when it deferred rendering', 2, ->
  context = Batman
    proceed: false
    foo: Batman
      foo: "bar"

  source = '<div data-context-alias="foo"><div data-renderif="proceed"><span data-bind="alias.foo">unrendered</span></div></div>'

  helpers.render source, context, (node) ->
    equal $('span', node).html(), 'unrendered'
    context.set('proceed', true)
    delay ->
      equal $('span', node).html(), 'bar'

asyncTest 'it should continue rendering on the node it stopped rendering', 2, ->
  context = Batman
    proceed: false
    foo: "bar"

  source = '<div data-bind="foo" data-renderif="proceed" >unrendered</div>'

  helpers.render source, context, (node) ->
    equal node.html(), 'unrendered'
    context.set('proceed', true)
    delay ->
      equal node.html(), 'bar'

asyncTest 'it should only render the inner nodes once', 3, ->
  context = Batman
    proceed: false
  context.accessor 'deferred', spy = createSpy().whichReturns('inner value')

  source = '<div data-renderif="proceed"><span data-bind="deferred">unrendered</span></div>'
  class InstrumentedRenderer extends Batman.Renderer
    @instanceCount: 0
    constructor: ->
      InstrumentedRenderer.instanceCount++
      super

  oldRenderer = Batman.Renderer
  Batman.Renderer = InstrumentedRenderer

  helpers.render source, context, (node) ->
    equal InstrumentedRenderer.instanceCount, 1
    context.set('proceed', true)
    delay ->
      equal InstrumentedRenderer.instanceCount, 2
      context.set('proceed', false)
      context.set('proceed', true)
      delay ->
        equal InstrumentedRenderer.instanceCount, 2
        Batman.Renderer = oldRenderer
