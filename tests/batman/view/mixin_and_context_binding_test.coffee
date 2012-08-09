helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module "Batman.View: mixin and context bindings"

asyncTest 'it should allow mixins to be applied', 1, ->
  Batman.mixins.set 'test',
    foo: 'bar'

  source = '<div data-mixin="test"></div>'
  helpers.render source, false, (node) ->
    equal Batman.data(node.firstChild, 'foo'), 'bar'
    delete Batman.mixins.test
    QUnit.start()

asyncTest 'it should allow contexts to be entered', 2, ->
  context = Batman
    namespace: Batman
      foo: 'bar'
  source = '<div data-context="namespace"><span id="test" data-bind="foo"></span></div>'
  helpers.render source, context, (node) ->
    equal $('#test', node).html(), 'bar'
    context.set('namespace', Batman(foo: 'baz'))
    equal $("#test", node).html(), 'baz', 'if the context changes the bindings should update'
    QUnit.start()

asyncTest 'contexts should only be available inside the node with the context directive', 2, ->
  context = Batman
    namespace: Batman
      foo: 'bar'
  source = '<div data-context="namespace"></div><span id="test" data-bind="foo"></span>'

  helpers.render source, context, (node) ->
    equal node[1].innerHTML, ""
    context.set('namespace', Batman(foo: 'baz'))
    equal node[1].innerHTML, ""
    QUnit.start()

asyncTest 'contexts should be available on the node with the context directive', 2, ->
  context = Batman
    namespace: Batman
      foo: 'bar'
  source = '<div data-context="namespace" data-bind="foo"></div>'

  helpers.render source, context, (node) ->
    equal node[0].innerHTML, "bar"
    context.set('namespace', Batman(foo: 'baz'))
    equal node[0].innerHTML, "baz"
    QUnit.start()

asyncTest 'it should allow context names to be specified', 2, ->
  context = Batman
    namespace: 'foo'
  source = '<div data-context-identifier="namespace"><span id="test" data-bind="identifier"></span></div>'
  helpers.render source, context, (node) ->
    equal $('#test', node).html(), 'foo'
    context.set('namespace', 'bar')
    equal $("#test", node).html(), 'bar', 'if the context changes the bindings should update'
    QUnit.start()

asyncTest 'it should allow contexts to be specified using filters', 2, ->
  context = Batman
    namespace: Batman
      foo: Batman
        bar: 'baz'
    keyName: 'foo'

  source = '<div data-context="namespace | get keyName"><span id="test" data-bind="bar"></span></div>'
  helpers.render source, context, (node) ->
    equal $('#test', node).html(), 'baz'
    context.set('namespace', Batman(foo: Batman(bar: 'qux')))
    equal $("#test", node).html(), 'qux', 'if the context changes the bindings should update'
    QUnit.start()
