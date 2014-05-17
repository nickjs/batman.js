helpers = window.viewHelpers

getSelections = (node) -> node.find('option').map((i, node) -> !!node.selected).toArray()
getContents = (node) -> node.find('option').map((i, node) -> node.innerHTML).toArray()

QUnit.module 'Batman.View select bindings'

asyncTest 'it should bind the value of a select box and update when the javascript land value changes', 2, ->
  context =
    heros: new Batman.Set(['mario', 'crono', 'link'])
    selected: new Batman.Object(name: 'crono')
  helpers.render '<select data-bind="selected.name"><option data-foreach-hero="heros" data-bind-value="hero"></option></select>', context, (node, view) ->
    equal node[0].value, 'crono'
    view.set('selected.name', 'link')
    equal node[0].value, 'link'
    QUnit.start()

asyncTest 'it should bind the value of a select box and update when options change', 7, ->
  context =
    heros: new Batman.Set()
    selected: new Batman.Object(name: 'crono')
  helpers.render '<select data-bind="selected.name"><option data-foreach-hero="heros" data-bind-value="hero" data-bind="hero | capitalize"></option></select>', context, (node, view) ->
    equal node[0].value, ''
    equal view.get('selected.name'), 'crono'
    view.get('heros').add('mario', 'link', 'crono')
    delay ->
      equal node[0].value, 'crono'
      deepEqual getContents(node), ['Mario', 'Link', 'Crono']
      equal view.get('selected.name'), 'crono'
      view.set('selected.name', 'mario')
      equal node[0].value, 'mario'
      deepEqual getContents(node), ['Mario', 'Link', 'Crono']

asyncTest 'it should bind the value of a select box and update the javascript land value with the selected option', 3, ->
  context =
    heros: new Batman.SimpleSet(['mario', 'crono', 'link'])
    selected: 'crono'
  helpers.render '<select data-bind="selected"><option data-foreach-hero="heros" data-bind-value="hero"></option></select>', context, (node, view) ->
    equal node[0].value, 'crono'
    view.set('selected', 'link')
    equal node[0].value, 'link'
    view.set('selected', 'mario')
    equal node[0].value, 'mario'
    QUnit.start()

asyncTest 'it binds the options of a select box and updates when the select\'s value changes', ->
  context =
    something: 'crono'
    mario: Batman(selected: null)
    crono: Batman(selected: null)

  helpers.render '<select data-bind="something"><option value="mario" data-bind-selected="mario.selected">Mario</option><option value="crono" data-bind-selected="crono.selected">Crono</option></select>', context, (node, view) ->
    equal node[0].value, 'crono'
    equal view.get('crono.selected'), true
    equal view.get('mario.selected'), false
    deepEqual getContents(node), ['Mario', 'Crono']

    node[0].value = 'mario'
    helpers.triggerChange node[0]
    equal view.get('mario.selected'), true
    equal view.get('crono.selected'), false
    deepEqual getContents(node), ['Mario', 'Crono']

    QUnit.start()

asyncTest 'it binds options created by a foreach and remains consistent when the set instance iterated over swaps', ->
  leo = Batman name: 'leo', id: 1
  mikey = Batman name: 'mikey', id: 2

  context =
    heroes: new Batman.Set([leo, mikey]).sortedBy('id')
    selected: 1

  helpers.render  '<select data-bind="selected">' +
                    '<option data-foreach-hero="heroes" data-bind-value="hero.id" data-bind="hero.name" />' +
                  '</selected>', context, (node, view) ->
    delay ->
      deepEqual getContents(node), ['leo', 'mikey']
      equal node[0].value, "1"

      view.set('heroes', new Batman.Set([leo, mikey]).sortedBy('id'))
      delay ->
        deepEqual getContents(node), ['leo', 'mikey']
        equal node[0].value, "1"

asyncTest 'it binds the value of a multi-select box and updates the options when the bound value changes', ->
  context =
    heros: new Batman.Set(['mario', 'crono', 'link', 'kirby'])
    selected: new Batman.Object(name: ['crono', 'link'])
  helpers.render '<select multiple="multiple" size="2" data-bind="selected.name"><option data-foreach-hero="heros" data-bind-value="hero" data-bind="hero | capitalize"></option></select>', context, (node, view) ->
    deepEqual getSelections(node), [no, yes, yes, no]
    deepEqual getContents(node), ['Mario', 'Crono', 'Link', 'Kirby']

    view.set('selected.name', ['mario', 'kirby'])

    deepEqual getSelections(node), [yes, no, no, yes]
    deepEqual getContents(node), ['Mario', 'Crono', 'Link', 'Kirby']
    QUnit.start()

asyncTest 'it binds the value of a multi-select box and updates the options when the options changes', ->
  context =
    heros: new Batman.Set()
    selected: new Batman.Object(names: ['crono', 'link'])

  source = '''
    <select multiple="multiple" size="2" data-bind="selected.names">
      <option data-foreach-hero="heros" data-bind-value="hero" data-bind="hero | capitalize"></option>
    </select>
  '''

  helpers.render source, context, (node, view) ->
    deepEqual view.get('selected.names'), ['crono', 'link']
    deepEqual getSelections(node), []
    deepEqual getContents(node), []

    view.get('heros').add 'mario', 'crono', 'link', 'kirby'
    delay ->
      deepEqual getSelections(node), [no, yes, yes, no]
      deepEqual getContents(node), ['Mario', 'Crono', 'Link', 'Kirby']

      view.set 'selected.names', ['mario', 'kirby']
      deepEqual getSelections(node), [yes, no, no, yes]
      deepEqual getContents(node), ['Mario', 'Crono', 'Link', 'Kirby']

      view.get('heros').clear()
      delay ->
        deepEqual view.get('selected.names'), ['mario', 'kirby']
        deepEqual getContents(node), []

asyncTest 'it binds the value of a multi-select box and updates the value when the selected options change', ->
  context =
    selected: 'crono'
    mario: new Batman.Object(selected: null)
    crono: new Batman.Object(selected: null)

  helpers.render '<select multiple="multiple" data-bind="selected"><option value="mario" data-bind-selected="mario.selected"></option><option value="crono" data-bind-selected="crono.selected"></option></select>', context, (node, view) ->
    equal node[0].value, 'crono', 'node value is crono'
    equal view.get('selected'), 'crono', 'selected is crono'
    equal view.get('crono.selected'), true, 'crono is selected'
    equal view.get('mario.selected'), false, 'mario is not selected'

    view.set 'mario.selected', true
    equal view.get('mario.selected'), true, 'mario is selected'
    equal view.get('crono.selected'), true, 'crono is still selected'
    deepEqual view.get('selected'), ['mario', 'crono'], 'mario and crono are selected in binding'
    for opt in node[0].children
      ok opt.selected, "#{opt.value} option is selected"
    QUnit.start()

asyncTest 'it binds multiple select options created by a foreach and remains consistent when the set instance iterated over swaps', 4, ->
  context =
    mario: mario = new Batman.Object(selected: false, name: 'mario')
    crono: crono = new Batman.Object(selected: true, name: 'crono')
    heros: new Batman.Set([mario, crono]).sortedBy('name')

  source = '''
    <select multiple="multiple">
      <option data-foreach-hero="heros" data-bind-selected="hero.selected" data-bind="hero.name" data-bind-value="hero.name"></option>
    </select>
  '''

  helpers.render source, context, (node, view) ->
    deepEqual getContents(node), ['crono', 'mario']
    deepEqual getSelections(node), [true, false]
    view.set('heros', new Batman.Set([view.get('crono'), view.get('mario')]).sortedBy('name'))
    delay ->
      deepEqual getContents(node), ['crono', 'mario']
      deepEqual getSelections(node), [true, false]

asyncTest 'should be able to destroy bound select nodes', 2, ->
  context = selected: "foo"
  helpers.render '<select data-bind="selected"><option value="foo">foo</option></select>', context, (node, view) ->
    Batman.DOM.destroyNode(node[0])
    deepEqual Batman.data(node[0]), {}
    deepEqual Batman._data(node[0]), {}
    QUnit.start()

asyncTest "should select an option with value='' when the data is undefined", ->
  context =
    current: Batman
      bar: 'foo'

  source = '''
    <select data-bind="current.bar">
      <option value="">none</option>
      <option value="foo">foo</option>
    </select>
  '''

  helpers.render source, context, (node, view) ->
    equal node[0].value, 'foo'
    deepEqual getContents(node), ['none', 'foo']

    view.unset('current.bar')
    equal typeof view.get('current.bar'), 'undefined'
    equal node[0].value, ''
    deepEqual getContents(node), ['none', 'foo']
    delay ->
      equal typeof view.get('current.bar'), 'undefined'
      equal node[0].value, ''
      deepEqual getContents(node), ['none', 'foo']

asyncTest "should select an option with value='' when the data is null", ->
  context =
    current: Batman
      bar: 'foo'

  source = '''
    <select data-bind="current.bar">
      <option value="">none</option>
      <option value="foo">foo</option>
    </select>
  '''

  helpers.render source, context, (node, view) ->
    equal node[0].value, 'foo'
    deepEqual getContents(node), ['none', 'foo']

    view.set('current.bar', null)
    equal view.get('current.bar'), null
    equal node[0].value, ''
    deepEqual getContents(node), ['none', 'foo']
    delay ->
      equal view.get('current.bar'), null
      equal node[0].value, ''
      deepEqual getContents(node), ['none', 'foo']


asyncTest "should select an option with value='' when the data is ''", ->
  context = current: 'foo'

  source = '''
    <select data-bind="current">
      <option value="">none</option>
      <option value="foo">foo</option>
    </select>
  '''

  helpers.render source, context, (node, view) ->
    equal node[0].value, 'foo'
    deepEqual getContents(node), ['none', 'foo']

    view.set('current', '')
    equal view.get('current'), ''
    equal node[0].value, ''
    deepEqual getContents(node), ['none', 'foo']

    delay ->
      equal view.get('current'), ''
      equal node[0].value, ''
      deepEqual getContents(node), ['none', 'foo']
