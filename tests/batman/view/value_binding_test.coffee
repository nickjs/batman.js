helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.View value bindings'

asyncTest 'it should allow arbitrary attributes to be bound', 2, ->
  source = '<div data-bind-foo="one" data-bind-data-bar="two" foo="before"></div>'
  helpers.render source,
    one: "baz"
    two: "qux"
  , (node) ->
    equal $(node[0]).attr('foo'), "baz"
    equal $(node[0]).attr('data-bar'), "qux"
    QUnit.start()

asyncTest 'it should bind undefined values as empty strings on attributes', 1, ->
  helpers.render '<div data-bind-src="foo"></div>', {}, (node) ->
    equal node[0].src, ""
    QUnit.start()

asyncTest 'it should allow input values to be bound', 1, ->
  helpers.render '<input data-bind="one" type="text" />',
    one: "qux"
  , (node) ->
    equal $(node[0]).val(), 'qux'
    QUnit.start()

asyncTest 'input value bindings should not escape their value', 1, ->
  helpers.render '<input data-bind="foo"></input>',
    foo: '<script></script>'
  , (node) =>
    equal node.val(), "<script></script>"
    QUnit.start()

asyncTest 'it should bind the input value and update the input when it changes', 2, ->
  context = Batman
    one: "qux"

  helpers.render '<input data-bind="one" type="text" />', context, (node) ->
    equal $(node[0]).val(), 'qux'
    context.set('one', "bar")
    equal $(node[0]).val(), 'bar'
    QUnit.start()

asyncTest 'it should bind the input value but not update the window object if the input changes', 2, ->
  context = Batman({})

  helpers.render '<input data-bind="nonexistantKey" type="text" />', context, (node) ->
    equal node[0].value, ''
    node[0].value = 'foo'
    helpers.triggerChange(node[0])
    equal typeof window.nonexistantKey, 'undefined'
    QUnit.start()

asyncTest 'it should bind the input value but not update the window object if the input changes with a many segment keypath', 2, ->
  context = Batman({})

  helpers.render '<input data-bind="someKey.path" type="text" />', context, (node) ->
    equal node[0].value, ''
    node[0].value = 'foo'
    helpers.triggerChange(node[0])
    delay ->
      equal typeof window.someKey, 'undefined'

asyncTest 'it should bind the input value of checkboxes and update the value when the object changes', 2, ->
  context = Batman
    one: true

  helpers.render '<input type="checkbox" data-bind="one" />', context, (node) ->
    equal node[0].checked, true
    context.set('one', false)
    equal node[0].checked, false
    QUnit.start()

asyncTest 'it should bind the input value of checkboxes and update the object when the value changes', 1, ->
  context = Batman
    one: true

  helpers.render '<input type="checkbox" data-bind="one" />', context, (node) ->
    node[0].checked = false
    helpers.triggerChange(node[0])
    equal context.get('one'), false
    QUnit.start()

asyncTest 'it should bind the input value and update the object when it changes', 1, ->
  context = new Batman.Object
    one: "qux"

  helpers.render '<input data-bind="one" type="text" />', context, (node) ->
    $(node[0]).val('bar')
    # Use DOM level 2 event dispatch, $().trigger doesn't seem to work
    helpers.triggerChange(node[0])
    equal context.get('one'), 'bar'
    QUnit.start()

asyncTest 'it should bind the input value and update the object when it keyups', 1, ->
  context = new Batman.Object
    one: "qux"

  helpers.render '<input data-bind="one" type="text" />', context, (node) ->
    $(node[0]).val('bar')
    # Use DOM level 2 event dispatch, $().trigger doesn't seem to work
    helpers.triggerKey(node[0], 82) # 82 is r from "bar"
    equal context.get('one'), 'bar'
    QUnit.start()

for type in ['text', 'search', 'tel', 'url', 'email', 'password']
  do (type) ->
    asyncTest "it should bind the input value on HTML5 input #{type} and update the object when it keyups", 1, ->
      context = new Batman.Object
        one: "qux"

      helpers.render "<input data-bind=\"one\" type=\"#{type}\"></input>", context, (node) ->
        $(node[0]).val('bar')
        # Use DOM level 2 event dispatch, $().trigger doesn't seem to work
        helpers.triggerKey(node[0], 82) # 82 is r from "bar"
        equal context.get('one'), 'bar'
        QUnit.start()

asyncTest 'it should bind the value of textareas', 2, ->
  context = new Batman.Object
    one: "qux"

  helpers.render '<textarea data-bind="one"></textarea>', context, (node) ->
    equal node.val(), 'qux'
    context.set('one', "bar")
    equal node.val(), 'bar'
    QUnit.start()

asyncTest 'textarea value bindings should not escape their value', 2, ->
  helpers.render '<textarea data-bind="foo"></textarea>',
    foo: '<script></script>'
  , (node) =>
    # jsdom and the browser have different behaviour, so lets just test against a node with the expected contents
    # to see if they are the same
    textarea = $('<textarea>').val("<script></script>")
    equal node.html(), textarea.html()
    equal node.val(), textarea.val()
    QUnit.start()

asyncTest 'it should bind the value of textareas and inputs simulatenously', ->
  context = new Batman.Object
    one: "qux"

  helpers.render '<textarea data-bind="one"></textarea><input data-bind="one" type="text"/>', context, (node) ->
    f = (v) =>
      equal $(node[0]).val(), v
      equal $(node[1]).val(), v
    f('qux')

    $(node[1]).val('bar')
    helpers.triggerChange(node[1])
    delay =>
      f('bar')
      $(node[0]).val('baz')
      helpers.triggerChange(node[0])
      delay =>
        f('baz')
        $(node[1]).val('foo')
        helpers.triggerChange(node[1])
        delay =>
          f('foo')

unless IN_NODE # jsdom doesn't seem to like input type="file"

  getMockModel = ->
    class Model extends Batman.Object
      storageKey: 'one'
      hasStorage: -> true
      fileAttributes: ''

    adapter = new Batman.RestStorage(Model)
    Model::_batman.storage = adapter

    [new Model, adapter]

  asyncTest 'it should bind the value of file type inputs', 2, ->
    [context, adapter] = getMockModel()
    ok !adapter.defaultRequestOptions.formData

    helpers.render '<input type="file" data-bind="fileAttributes"></input>', false, context, (node) ->
      helpers.triggerChange(node.childNodes[0])
      strictEqual context.fileAttributes, undefined
      QUnit.start()

  asyncTest 'it should bind the value of file type inputs with the "multiple" flag', 2, ->
    [context, adapter] = getMockModel()
    ok !adapter.defaultRequestOptions.formData

    helpers.render '<input type="file" data-bind="fileAttributes" multiple="multiple"></input>', false, context, (node) ->
      helpers.triggerChange(node.childNodes[0])
      deepEqual context.fileAttributes, []
      QUnit.start()

  asyncTest 'it should bind the value of file type inputs when they are proxied', 2, ->
    [context, adapter] = getMockModel()
    ok !adapter.defaultRequestOptions.formData

    source = '<form data-formfor-foo="proxied"><input type="file" data-bind="foo.fileAttributes"></input></form>'

    helpers.render source, false, {proxied: context}, (node) ->
      helpers.triggerChange(node.childNodes[0].childNodes[0])
      strictEqual context.fileAttributes, undefined
      QUnit.start()

asyncTest 'should bind radio buttons to a value', ->
  source = '<input id="fixed" type="radio" data-bind="ad.sale_type" name="sale_type" value="fixed"/>
    <input id="free" type="radio" data-bind="ad.sale_type" name="sale_type" value="free"/>
    <input id="trade" type="radio" data-bind="ad.sale_type" name="sale_type" value="trade"/>'
  context = Batman
    ad: Batman
      sale_type: 'free'

  helpers.render source, context, (node) ->
    fixed = node[0]
    free = node[1]
    trade = node[2]

    ok (!fixed.checked and free.checked and !trade.checked)

    context.set 'ad.sale_type', 'trade'
    ok (!fixed.checked and !free.checked and trade.checked)
    QUnit.start()

asyncTest 'should bind to the value of radio buttons', ->
  source = '''
    <input id="fixed" type="radio" data-bind="ad.sale_type" name="sale_type" value="fixed"/>
    <input id="free" type="radio" data-bind="ad.sale_type" name="sale_type" value="free"/>
    <input id="trade" type="radio" data-bind="ad.sale_type" name="sale_type" value="trade" checked/>
  '''

  context = Batman
    ad: Batman()

  helpers.render source, context, (node) ->
    fixed = node[0]
    free = node[1]
    trade = node[2]

    ok !fixed.checked
    ok !free.checked
    ok trade.checked
    equal context.get('ad.sale_type'), 'trade', 'checked attribute binds'

    fixed.checked = true
    helpers.triggerChange(fixed)
    equal context.get('ad.sale_type'), 'fixed'
    QUnit.start()

asyncTest 'should bind to true and false values', ->
  source = '''
    <input type="radio" data-bind="ad.published" name="published" value="false" checked />
    <input type="radio" data-bind="ad.published" name="published" value="true"/>
  '''

  context = Batman
    ad: Batman()

  helpers.render source, context, (node) ->
    hidden = node[0]
    published = node[1]

    ok !published.checked
    ok hidden.checked

    strictEqual context.get('ad.published'), false
    context.set 'ad.published', true
    ok published.checked
    ok !hidden.checked

    hidden.checked = true
    helpers.triggerChange hidden
    equal context.get('ad.published'), false

    QUnit.start()
