helpers = window.viewHelpers

QUnit.module 'Batman.View style attribute bindings'

asyncTest 'it should allow multiple properties to be bound', 4, ->
  source = '<div data-style-background-color="foo" data-style-margin-top="bar"></div>'
  helpers.render source,
    foo: 'red'
    bar: '4px'
  , (node, view) ->
    equal node[0].style.backgroundColor, 'red'
    equal node[0].style.marginTop, '4px'

    view.set('foo', 'blue')
    view.set('bar', '21em')
    equal node[0].style.backgroundColor, 'blue'
    equal node[0].style.marginTop, '21em'

    QUnit.start()

