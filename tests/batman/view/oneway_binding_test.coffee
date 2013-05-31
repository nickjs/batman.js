helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.View: one-way bindings'

asyncTest 'target should update only the javascript value', 3, ->
  source = '<input type="text" data-target="foo" value="start"/>'
  helpers.render source, false, {foo: null}, (node, view) ->
    node = node.children[0]
    equal node.value, 'start'

    node.value = 'bar'
    helpers.triggerChange(node)
    equal view.get('foo'), 'bar'

    view.set('foo', 'baz')
    equal node.value, 'bar'
    QUnit.start()

asyncTest 'target should get the value from the node upon binding', 1, ->
  source = '<input type="text" data-target="foo" value="start"/>'
  helpers.render source, {foo: null}, (node, view) ->
    equal view.get('foo'), 'start'
    QUnit.start()

asyncTest 'source should update only the bound node', 3, ->
  source = '<input type="text" data-source="foo" value="start"/>'
  helpers.render source, {foo: 'bar'}, (node, view) ->
    node = node[0]
    equal node.value, 'bar'

    node.value = 'baz'
    helpers.triggerChange node
    equal view.get('foo'), 'bar'

    view.set('foo', 'end')
    equal node.value, 'end'

    QUnit.start()

asyncTest 'attribute source should update only the bound attribute on the node', 3, ->
  source = '<input type="text" data-source-width="foo.width" value="start" width="10"/>'
  context =
    foo: Batman
      width: 20

  helpers.render source, context, (node, view) ->
    node = node[0]
    equal node.getAttribute('width'), '20'
    node.setAttribute 'width', 30

    helpers.triggerChange node
    equal view.get('foo.width'), 20 # nodeChange has no effect

    view.set 'foo.width', 40
    equal node.getAttribute('width'), '40'

    QUnit.start()

asyncTest 'data-source and data-target work correctly on the same node', ->
  source = '<input type="text" data-target="there" data-source="here" value="start"/>'
  context = here: 'here', there: ''

  helpers.render source, context, (node, view) ->
    node = node[0]
    equal node.value, 'here'
    equal view.get('there'), 'here'

    node.value = 'there'
    helpers.triggerChange node
    equal view.get('there'), 'there'
    equal view.get('here'), 'here'

    QUnit.start()
