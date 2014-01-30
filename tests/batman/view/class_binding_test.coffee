helpers = window.viewHelpers

QUnit.module 'Batman.View class bindings',
asyncTest 'it should allow a class to be bound', 6, ->
  source = '<div data-addclass-one="foo" data-removeclass-two="bar" class="zero"></div>'
  helpers.render source,
    foo: true
    bar: true
  , (node) ->
    ok node.hasClass('zero')
    ok node.hasClass('one')
    ok !node.hasClass('two')

    helpers.render source,
      foo: false
      bar: false
    , (node) ->
      ok node.hasClass('zero')
      ok !node.hasClass('one')
      ok node.hasClass('two')
      QUnit.start()

asyncTest 'it should allow a multiple similiar class names to be bound', 7, ->
  source = '<div data-addclass-answered="foo" data-addclass-reanswered="bar" class="unanswered"></div>'
  helpers.render source,
    foo: true
    bar: true
  , (node) ->
    ok node.hasClass('unanswered')
    ok node.hasClass('answered')
    ok node.hasClass('reanswered')

    helpers.render source,
      foo: false
      bar: true
    , (node) ->
      ok node.hasClass('unanswered')
      ok node.hasClass('reanswered')
      ok !node.hasClass('answered')
      ok !node.hasClass('un')
      QUnit.start()

asyncTest 'it should allow multiple class names to be bound and updated', ->
  source = '<div data-bind-class="classes"></div>'
  context = Batman classes: 'foo bar'
  helpers.render source, context, (node, view) ->
    equal node[0].className, 'foo bar'
    view.set('classes', 'bar baz')
    equal node[0].className, 'bar baz'
    QUnit.start()


asyncTest 'it should allow an already present class to be removed', 6, ->
  source = '<div data-removeclass-two="bar" class="zero two three"></div>'
  context = Batman
    foo: true
    bar: false
  helpers.render source, context, (node, view) ->
    ok node.hasClass('zero')
    ok node.hasClass('two')
    ok node.hasClass('three')

    view.set('bar', true)
    ok node.hasClass('zero')
    ok !node.hasClass('two')
    ok node.hasClass('three')

    QUnit.start()

asyncTest 'it should not remove an already present similar class name', 6, ->
  source = '<div data-removeclass-foobar="bar" class="zero bar"></div>'
  context = Batman
    foo: true
    bar: false
  helpers.render source, context, (node, view) ->
    ok node.hasClass('zero')
    ok node.hasClass('bar')
    ok node.hasClass('foobar')

    view.set('bar', true)
    ok node.hasClass('zero')
    ok node.hasClass('bar')
    ok !node.hasClass('foobar')

    QUnit.start()

asyncTest 'it should allow multiple class names to be bound and updated via set', ->
  source = '<div data-bind-class="classes"></div>'
  context = Batman
    classes: new Batman.Set('foo', 'bar', 'baz')

  helpers.render source, context, (node, view) ->
    ok node.hasClass('foo')
    ok node.hasClass('bar')
    ok node.hasClass('baz')

    view.get('classes').remove('foo')
    ok !node.hasClass('foo')
    ok node.hasClass('bar')
    ok node.hasClass('baz')

    QUnit.start()

asyncTest 'it should allow multiple class names to be bound and updated via hash', ->
  source = '<div data-bind-class="classes"></div>'
  context = Batman
    classes: new Batman.Hash
      foo: true
      bar: true
      baz: true

  helpers.render source, context, (node, view) ->
    equal node[0].className, 'foo bar baz'
    view.get('classes').unset('foo')
    equal node[0].className, 'bar baz'

    QUnit.start()

asyncTest 'it should allow multiple class names to be bound via object', ->
  source = '<div data-bind-class="classes"></div>'
  context = Batman
    classes:
      foo: true
      bar: true
      baz: true

  helpers.render source, context, (node, view) ->
    equal node[0].className, 'foo bar baz'
    view.set('classes', {bar: true, baz: true})
    equal node[0].className, 'bar baz'
    QUnit.start()


asyncTest 'it should allow multiple class names to be delimited by "|"', ->
  source = '<div data-addclass-foo|bar="val"></div>'

  helpers.render source, val: false, (node, view) ->
    equal node[0].className, ''
    view.set('val', true)
    ok node.hasClass('foo')
    ok node.hasClass('bar')
    QUnit.start()

asyncTest 'it shouldn\'t create redundant whitespace', ->
  source = '<div class="" data-addclass-foo="foo" data-addclass-bar="bar"></div>'

  helpers.render source, {foo: false, bar: false}, (node, view) ->
    equal node[0].className, ''
    view.set('foo', not view.get('foo')) for i in [1..10]
    equal node[0].className, ''
    view.set('foo', true)
    equal node[0].className, 'foo'
    view.set('bar', true)
    equal node[0].className, 'foo bar'
    view.set('bar', false)
    equal node[0].className, 'foo'
    QUnit.start()

asyncTest 'it should not remove already existing classes when binding a new (single) class', ->
  source = '<div data-bind-class="fish" class="onefish twofish"></div>'
  helpers.render source, { fish: false }, (node, view) ->
    ok node.hasClass('onefish')
    ok node.hasClass('twofish')
    view.set('fish', 'newfish')
    ok node.hasClass('onefish')
    ok node.hasClass('twofish')
    ok node.hasClass('newfish')
    QUnit.start()

asyncTest 'it should not remove already existing classes when binding new (multiple) classes', ->
  source = '<div data-bind-class="fish" class="onefish twofish"></div>'
  helpers.render source, { fish: false }, (node, view) ->
    ok node.hasClass('onefish')
    ok node.hasClass('twofish')
    view.set 'fish', new Batman.Set('redfish', 'blufish')
    ok node.hasClass('onefish')
    ok node.hasClass('twofish')
    ok node.hasClass('redfish')
    ok node.hasClass('blufish')
    view.set 'fish',
      new Batman.Hash
        'oldfish': true
        'newfish': true
    ok node.hasClass('onefish')
    ok node.hasClass('twofish')
    ok node.hasClass('oldfish')
    ok node.hasClass('newfish')
    view.set 'fish',
      {
        'hotfish': true
        'cldfish': true
      }
    ok node.hasClass('onefish')
    ok node.hasClass('twofish')
    ok node.hasClass('hotfish')
    ok node.hasClass('cldfish')
    QUnit.start()

asyncTest 'it should not add already existing classes when binding a new (single) class', ->
  source = '<div data-bind-class="fish" class="onefish twofish"></div>'
  helpers.render source, { fish: false }, (node, view) ->
    equal node[0].className.split(" ").length, 2
    view.set('fish', 'newfish')
    equal node[0].className.split(" ").length, 3
    QUnit.start()

asyncTest 'it should not add already existing classes when binding new (multiple) classes', ->
  source = '<div data-bind-class="fish" class="onefish twofish"></div>'
  helpers.render source, { fish: false }, (node, view) ->
    equal node[0].className.split(" ").length, 2
    view.set 'fish', new Batman.Set('redfish', 'blufish')
    equal node[0].className.split(" ").length, 4
    view.set 'fish',
      new Batman.Hash
        'oldfish': true
        'newfish': true
    equal node[0].className.split(" ").length, 4
    view.set 'fish',
      {
        'hotfish': true
        'cldfish': true
      }
    equal node[0].className.split(" ").length, 4
    QUnit.start()
