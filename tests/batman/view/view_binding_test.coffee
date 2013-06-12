helpers = window.viewHelpers

class TestView extends Batman.View
  constructor: ->
    @prevent('ready')

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
