helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.View simple rendering'

hte = (actual, expected) ->
  equal actual.innerHTML.toLowerCase().replace(/\n|\r/g, ""),
    expected.toLowerCase().replace(/\n|\r/g, "")

test "Batman.Renderer::_sortBindings should be consistent", ->
  bindings = [["a"], ["foreach"], ["c"], ["bind"], ["b"], ["context"], ["f"], ["view"], ["g"], ["formfor"], ["d"], ["renderif"], ["e"]]
  expectedSort = [["view"], ["renderif"], ["foreach"], ["formfor"], ["context"], ["bind"], ["a"], ["b"], ["c"], ["d"], ["e"], ["f"], ["g"]]
  deepEqual bindings.sort(Batman.Renderer::_sortBindings), expectedSort

test 'it should render simple nodes', ->
  hte helpers.render("<div></div>", false), "<div></div>"

test 'it should render many parent nodes', ->
  hte helpers.render("<div></div><p></p>", false), "<div></div><p></p>"

asyncTest 'it should allow the inner value to be bound', 1, ->
  helpers.render '<div data-bind="foo"></div>',
    foo: 'bar'
  , (node) =>
    equal node.html(), "bar"
    QUnit.start()

asyncTest 'it should allow the inner value to be bound using content containing html', 1, ->
  helpers.render '<div data-bind="foo"></div>',
    foo: '<p>bar</p>'
  , (node) =>
    equal node.html(), "&lt;p&gt;bar&lt;/p&gt;"
    QUnit.start()

asyncTest 'it should track added bindings', 2, ->
  Batman.DOM.on 'bindingAdded', spy = createSpy()
  helpers.render '<div data-bind="foo"></div>',
    foo: 'bar'
  , (node) =>
    ok spy.called
    ok spy.lastCallArguments[0] instanceof Batman.DOM.AbstractBinding
    Batman.DOM.event('bindingAdded').removeHandler(spy)
    QUnit.start()

asyncTest 'it should bind undefined values as empty strings', 1, ->
  helpers.render '<div data-bind="foo"></div>',
    foo: undefined
  , (node) =>
    equal node.html(), ""
    QUnit.start()

asyncTest 'it should allow ! and ? at the end of a keypath', 1, ->
  helpers.render '<div data-bind="foo?"></div>',
    'foo?': 'bar'
  , (node) =>
    equal node.html(), "bar"
    QUnit.start()

asyncTest 'it should ignore empty bindings', 1, ->
  helpers.render '<div data-bind=""></div>', Batman(), (node) =>
    equal node.html(), ""
    QUnit.start()

asyncTest 'it should allow bindings to be defined later', 2, ->
  context = Batman()
  helpers.render '<div data-bind="foo.bar"></div>', context, (node) =>
    equal node.html(), ""
    context.set 'foo', Batman(bar: "baz")
    equal node.html(), "baz"
    QUnit.start()

asyncTest 'it should allow commenting of bindings', 1, ->
  helpers.render '<div x-data-bind="foo"></div>',
    foo: 'bar'
  , (node) =>
    equal node.html(), ""
    QUnit.start()

asyncTest 'it should correctly bind to a deep keypath when the base segment changes', 2, ->
  source = '<span data-bind="gadget.name"></span>'
  batarang = Batman name: 'batarang'
  sharkSpray = Batman name: 'shark spray'

  context = Batman gadget: batarang

  helpers.render source, context, (node) =>
    equal node[0].innerHTML, "batarang"

    context.set 'gadget', sharkSpray
    equal node[0].innerHTML, "shark spray"
    QUnit.start()

asyncTest 'bindings in lower down scopes should shadow higher ones', 3, ->
  context = Batman
    namespace: Batman
      foo: 'inner'
    foo: 'outer'
  helpers.render '<div data-context="namespace"><div id="inner" data-bind="foo"></div></div>', context, (node) =>
    node = $('#inner', node)
    equal node.html(), "inner"
    context.set 'foo', "outer changed"
    equal node.html(), "inner"
    context.set 'namespace.foo', 'inner changed'
    equal node.html(), "inner changed"
    QUnit.start()

asyncTest 'bindings in lower down scopes should shadow higher ones with shadowing defined as the base of the keypath being defined', 3, ->
  context = Batman
    namespace: Batman
      foo: Batman()
    foo: Batman
      bar: 'outer'

  helpers.render '<div data-context="namespace"><div id="inner" data-bind="foo.bar"></div></div>', context, (node) =>
    node = $('#inner', node)
    equal node.html(), ""
    context.set 'foo', "outer changed"
    equal node.html(), ""
    context.set 'namespace.foo.bar', 'inner'
    equal node.html(), "inner"
    QUnit.start()

asyncTest 'bindings which prevent and fire rendered on their parent renderer should not prematurely fire the event', ->
  context = Batman(bar: [], baz: '123')
  html = '''
    <div>
      test
      <p data-foreach-foo="context.bar"></p>
      test
    </div>
    <span data-bind="baz"></span>
  '''

  # helpers.render fires the callback on view ready, which fires on it's renderer's rendered
  helpers.render html, context, (node) =>
    equal node[1].innerHTML, "123"
    QUnit.start()
