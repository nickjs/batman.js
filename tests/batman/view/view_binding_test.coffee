helpers = window.viewHelpers

QUnit.module 'Batman.View data-view bindings'

asyncTest 'it should instantiate custom view classes with the node\'s HTML', 1, ->
  source = '<div data-view="someCustomClass">foo</div>'
  context = {someCustomClass: Batman.View}

  helpers.render source, context, (node, view) ->
    equal node.html(), 'foo'
    QUnit.start()

asyncTest 'it should set the node on already instantiated custom views', 1, ->
  source = '<div data-view="someCustomView">foo</div>'
  view = new Batman.View
  context = {someCustomView: view}

  delay =>
    equal view.get('node').innerHTML, 'foo'

  helpers.render source, context, ->

asyncTest 'it should not render inner nodes', ->
  source = '<div data-view="someCustomClass"><div data-bind="someProp"></div></div>'
  context = {someCustomClass: Batman.View, someProp: spy = createSpy()}

  helpers.render source, context, ->
    ok !spy.called
    QUnit.start()

asyncTest 'it should not render bindings on the node', ->
  source = '<div data-view="someCustomClass" data-bind="someProp"></div>'
  context = {someCustomClass: Batman.View, someProp: spy = createSpy()}

  helpers.render source, context, ->
    ok !spy.called
    QUnit.start()

QUnit.module 'Batman.View data-view argument bindings',
  setup: ->
    class @TestView extends Batman.View
      @option 'arg'

asyncTest 'it should properly bind to a view argument', 3, ->
  source = '<div data-view="someCustomClass" data-view-arg="viewArg"></div>'
  context =
    someCustomClass: new @TestView
    viewArg: 5

  helpers.render source, context, (node, view) ->
    subview = view.subviews.get('first')
    equal(subview.get('arg'), 5)

    view.set('viewArg', 10)
    equal(subview.get('arg'), 10)

    subview.set('arg', 8)
    equal(view.get('viewArg'), 8)

    QUnit.start()

asyncTest 'it should bind arguments through backing views', 4, ->
  source = '''
    <div data-context-foo="bar">
      <div data-view="someCustomClass" data-view-arg="foo"></div>
    </div>
  '''

  context =
    someCustomClass: new @TestView
    bar: 5

  helpers.render source, context, (node, view) ->
    context = view.subviews.get('first')
    innerView = context.subviews.get('first')

    equal(innerView.get('arg'), 5)

    view.set('bar', 10)
    equal(innerView.get('arg'), 10)

    innerView.set('arg', 12)
    equal(context.get('foo'), 12)
    equal(view.get('bar'), 12)

    QUnit.start()
