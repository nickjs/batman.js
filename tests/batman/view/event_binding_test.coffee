helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.View event bindings',

asyncTest 'it should allow events to be bound and execute them in the context as specified on a multi key keypath', 4, ->
  spy = createSpy()
  context = Batman
    foo: Batman
      bar: Batman
        doSomething: spy

  source = '<button data-event-click="foo.bar.doSomething"></button>'
  helpers.render source, context, (node, view) ->
    helpers.triggerClick(node[0])
    ok spy.called

    equal spy.lastCallContext, view
    equal spy.lastCallArguments[0], node[0]
    equal spy.lastCallArguments[2].get('foo'), view.get('foo')

    QUnit.start()

asyncTest 'it should allow events to be bound to undefined', ->
  QUnit.expect(0)

  spy = createSpy()
  context = Batman
    foo: Batman

  source = '<button data-event-click="foo.bar.doSomething"></button>'
  helpers.render source, context, (node) ->
    helpers.triggerClick(node[0])
    QUnit.start()

asyncTest 'it should use native property access instead of `get` to find event handlers', 1, ->
  spy = createSpy()
  class Test extends Batman.Object
    constructor: ->
      @attrs = new Batman.Hash
      super

    bar: spy

    @accessor
      get: (key) ->
        @attrs.get(key)
      set: (key, value) ->
        @attrs.set(key, value)

  context = Batman
    foo: new Test()

  source = '<button data-event-click="foo.bar"></button>'
  helpers.render source, context, (node) ->
    helpers.triggerClick(node[0])
    ok spy.called
    QUnit.start()

asyncTest 'it should allow events to be bound and execute them in the context as specified on terminal keypath', 3, ->
  context = Batman
    foo: 'bar'
    doSomething: spy = createSpy()

  source = '<button data-event-click="doSomething"></button>'
  helpers.render source, context, (node, view) ->
    helpers.triggerClick(node[0])
    equal spy.lastCallContext, view
    equal spy.lastCallArguments[0], node[0]
    equal spy.lastCallArguments[2].get('foo'), 'bar'

    QUnit.start()

asyncTest 'it should allow click events to be bound', 2, ->
  context =
    doSomething: spy = createSpy()

  source = '<button data-event-click="doSomething"></button>'
  helpers.render source, context, (node) ->
    helpers.triggerClick(node[0])
    ok spy.called
    equal spy.lastCallArguments[0], node[0]

    QUnit.start()

asyncTest 'it should allow double click events to be bound', 2, ->
  context =
    doSomething: spy = createSpy()

  source = '<button data-event-doubleclick="doSomething"></button>'
  helpers.render source, context, (node) ->
    helpers.triggerDoubleClick(node[0])
    ok spy.called
    equal spy.lastCallArguments[0], node[0]

    QUnit.start()

if document.createEvent
  asyncTest 'it should not execute click handlers for command clicks', 1, ->
    context =
      doSomething: spy = createSpy()

    source = '<button data-event-click="doSomething"></button>'
    helpers.render source, context, (node) ->
      helpers.triggerClick(node[0], undefined, {metaKey: true})
      ok !spy.called
      QUnit.start()

asyncTest 'it should not execute click handlers for middle clicks', 1, ->
  context =
    doSomething: spy = createSpy()

  source = '<button data-event-click="doSomething"></button>'
  helpers.render source, context, (node) ->
    helpers.triggerClick(node[0], undefined, {button: 1})
    ok !spy.called
    QUnit.start()

asyncTest 'it should allow un-special-cased events like focus to be bound', 2, ->
  context =
    doSomething: spy = createSpy()

  source = '<input type="text" data-event-focus="doSomething" value="foo"></input>'
  helpers.render source, context, (node) ->
    helpers.triggerFocus(node[0])
    ok spy.called
    equal spy.lastCallArguments[0], node[0]

    QUnit.start()

asyncTest 'it should allow event handlers to update', 3, ->
  context = Batman
    doSomething: spy = createSpy()

  source = '<button data-event-click="doSomething"></button>'
  helpers.render source, context, (node, view) ->
    helpers.triggerClick(node[0])
    ok spy.called

    view.set('doSomething', newSpy = createSpy())
    helpers.triggerClick(node[0])

    ok newSpy.called
    equal spy.callCount, 1

    QUnit.start()

asyncTest 'it should allow change events on checkboxes to be bound', 2, ->
  context = new Batman.Object
    one: true
    doSomething: createSpy()

  helpers.render '<input type="checkbox" data-bind="one" data-event-change="doSomething"/>', context, (node, view) ->
    node[0].checked = false
    helpers.triggerChange(node[0])
    ok context.doSomething.called
    equal context.doSomething.lastCallArguments[2], view

    QUnit.start()

asyncTest 'it should allow submit events on inputs to be bound', 3, ->
  context =
    doSomething: spy = createSpy()

  source = '<form><input data-event-submit="doSomething" /></form>'
  helpers.render source, context, (node, view) ->
    helpers.triggerKey(node[0].childNodes[0], 13)
    ok spy.called
    equal spy.lastCallArguments[0], node[0].childNodes[0]
    ok spy.lastCallArguments[2], view

    QUnit.start()

asyncTest 'it should ignore keyup events with no associated keydown events', 2, ->
  # This can happen when we move the focus between nodes while handling some of these events.
  context =
    doSomething: aSpy = createSpy()
    doAnother: anotherSpy = createSpy()

  source = '<form><input data-event-submit="doSomething" /><input data-event-submit="doAnother"></form>'
  helpers.render source, context, (node) ->
    helpers.triggerKey(node[0].childNodes[1], 13, ["keydown", "keypress"])
    helpers.triggerKey(node[0].childNodes[0], 13, ["keyup"])
    ok !aSpy.called
    ok !anotherSpy.called

    QUnit.start()

asyncTest 'it should allow form submit events to be bound', 2, ->
  context =
    doSomething: spy = createSpy()

  source = '<form data-event-submit="doSomething"><input type="submit" id="submit" /></form>'
  helpers.render source, context, (node) ->
    helpers.triggerSubmit(node[0])
    ok spy.called
    ok spy.lastCallArguments[2].lookupKeypath

    QUnit.start()

asyncTest 'should pass the context to other events without special handlers', 3, ->
  context =
    doSomething: spy = createSpy()

  source = '<form><input data-event-keypress="doSomething" /></form>'
  helpers.render source, context, (node) ->
    helpers.triggerKey(node[0].childNodes[0], 65)
    ok spy.called
    equal spy.lastCallArguments[0], node[0].childNodes[0]
    ok spy.lastCallArguments[2].lookupKeypath

    QUnit.start()

asyncTest 'it should not choke on proxied values which resolve to undefined', 1, ->
  source = '<div data-context-foo="bar"><input data-event-keypress="foo" /></div>'
  helpers.render source, {}, (node) ->
    helpers.triggerKey(node[0].childNodes[0], 65)
    ok true
    QUnit.start()

asyncTest 'it should provide an app-level hook for handling events', 1, ->
  source = '<a data-event-click="clicked">test</a>'

  class MockApp extends Batman.App
    @layout: null
    @shouldAllowEvent.click = ->
      ok true, 'shouldAllow called'
      true

  MockApp.run()

  helpers.render source, {clicked: ->}, (node) ->
    helpers.triggerClick node[0]
    QUnit.start()

asyncTest 'returning false from a shouldAllowEvent delegate should cancel the event', 1, ->
  source = """<div>
    <a data-event-click="clicked">should work</a>
    <a data-event-click="clicked" class="disabled">should not work</a>
  </div>"""

  class MockApp extends Batman.App
    @layout: null
    @shouldAllowEvent.click = (e) ->
      return false if $(e.target).hasClass('disabled')

  MockApp.run()

  helpers.render source, {clicked: -> ok(true, 'clicked was called')}, (node) ->
    helpers.triggerClick node[0].children[0]
    helpers.triggerClick node[0].children[1]
    QUnit.start()
