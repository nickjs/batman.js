helpers = window.viewHelpers

QUnit.module "Batman.View: context bindings"

asyncTest 'it should allow contexts to be entered', 2, ->
  context =
    namespace: Batman
      foo: 'bar'
  source = '<div data-context="namespace"><span id="test" data-bind="foo"></span></div>'

  helpers.render source, context, (node, view) ->
    equal $('#test', node).html(), 'bar'
    view.set('namespace', Batman(foo: 'baz'))
    equal $("#test", node).html(), 'baz', 'if the context changes the bindings should update'
    QUnit.start()

asyncTest 'contexts should only be available inside the node with the context directive', 2, ->
  context =
    namespace: Batman
      foo: 'bar'
  source = '<div data-context="namespace"></div><span id="test" data-bind="foo"></span>'

  helpers.render source, context, (node, view) ->
    equal node[1].innerHTML, ""
    view.set('namespace', Batman(foo: 'baz'))
    equal node[1].innerHTML, ""
    QUnit.start()

asyncTest 'contexts should be available on the node with the context directive', 2, ->
  context = namespace: Batman(foo: 'bar')
  source = '<div data-context="namespace" data-bind="foo"></div>'

  helpers.render source, context, (node, view) ->
    equal node[0].innerHTML, "bar"
    view.set('namespace', Batman(foo: 'baz'))
    equal node[0].innerHTML, "baz"
    QUnit.start()

asyncTest 'it should allow context names to be specified', 2, ->
  context = namespace: 'foo'
  source = '<div data-context-identifier="namespace"><span id="test" data-bind="identifier"></span></div>'

  helpers.render source, context, (node, view) ->
    equal $('#test', node).html(), 'foo'
    view.set('namespace', 'bar')
    equal $("#test", node).html(), 'bar', 'if the context changes the bindings should update'
    QUnit.start()

asyncTest 'it should allow contexts to be specified using filters', 2, ->
  context =
    namespace: Batman
      foo: Batman
        bar: 'baz'
    keyName: 'foo'

  source = '<div data-context="namespace | get keyName"><span id="test" data-bind="bar"></span></div>'
  helpers.render source, context, (node, view) ->
    equal $('#test', node).html(), 'baz'
    view.set('namespace', Batman(foo: Batman(bar: 'qux')))
    equal $("#test", node).html(), 'qux', 'if the context changes the bindings should update'
    QUnit.start()
