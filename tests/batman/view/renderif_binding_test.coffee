helpers = window.viewHelpers

QUnit.module "Batman.View: data-render-if bindings"

asyncTest 'should not render inner nodes until keypath is truthy', 4, ->
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

asyncTest 'should render inner nodes and remove attribute if keypath is truthy', 2, ->
  context = proceed: true, deferred: 'inner value'

  source = '<div class="foo" data-renderif="proceed"><span data-bind="deferred">unrendered</span></div>'

  helpers.render source, context, (node, view) ->
    equal $('span', node).html(), 'inner value'
    equal $('.foo', node).attr('data-renderif'), undefined

    QUnit.start()

asyncTest 'should render inner nodes in same context as node was in when it deferred rendering', 2, ->
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

asyncTest 'should continue rendering on node it stopped rendering', 2, ->
  context = proceed: false, foo: "bar"

  source = '<div data-bind="foo" data-renderif="proceed" >unrendered</div>'

  helpers.render source, context, (node, view) ->
    equal node.html(), 'unrendered'
    view.set('proceed', true)
    equal node.html(), 'bar'
    QUnit.start()

asyncTest 'should only render inner nodes once', 3, ->
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

QUnit.module "Batman.View: data-deferif bindings"

asyncTest 'should render inner nodes and remove attribute if keypath is falsy', 2, ->
  context = doNotProceed: false, deferred: 'inner value'

  source = '<div class="foo" data-deferif="doNotProceed"><span data-bind="deferred">unrendered</span></div>'

  helpers.render source, context, (node, view) ->
    equal $('span', node).html(), 'inner value'
    equal $('.foo', node).attr('data-deferif'), undefined

    QUnit.start()

asyncTest 'should not render inner nodes until keypath is falsy', 4, ->
  context = doNotProceed: true

  source = '<div data-deferif="doNotProceed"><span data-bind="deferred">unrendered</span></div>'

  helpers.render source, context, (node, view) ->
    view.accessor 'deferred', spy = createSpy().whichReturns('inner value')

    ok !spy.called
    equal $('span', node).html(), 'unrendered'

    view.set('doNotProceed', false)
    ok spy.called
    equal $('span', node).html(), 'inner value'

    QUnit.start()
