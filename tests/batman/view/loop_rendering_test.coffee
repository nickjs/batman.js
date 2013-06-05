helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'
getPs = (view) -> $('p', view.get('node')).map(-> @innerHTML).toArray()

QUnit.module "Batman.View loop rendering"

asyncTest 'it should allow simple loops', 1, ->
  source = '<p data-foreach-object="objects" class="present" data-bind="object"></p>'
  objects = new Batman.Set('foo', 'bar', 'baz')

  helpers.render source, {objects}, (node, view) ->
    deepEqual getPs(view), ['foo', 'bar', 'baz']
    QUnit.start()

asyncTest 'it should allow loops over empty collections', 1, ->
  source = '<p data-foreach-object="objects" class="present" data-bind="object"></p>'
  objects = new Batman.Set()

  helpers.render source, {objects}, (node, view) ->
    deepEqual getPs(view), []
    QUnit.start()

asyncTest 'it should allow loops over undefined values', 3, ->
  source = '<p data-foreach-object="objects" class="present" data-bind="object"></p>'
  Batman.developer.suppress()
  helpers.render source, {}, (node, view) ->
    deepEqual getPs(view), []
    view.set('objects', new Batman.Set('foo', 'bar', 'baz'))
    delay ->
      deepEqual getPs(view), ['foo', 'bar', 'baz']
      view.unset('objects')
      delay ->
        deepEqual getPs(view), []
        Batman.developer.unsuppress()

asyncTest 'it should render new items as they are added', ->
  source = '<div><p data-foreach-object="objects" class="present" data-bind="object"></p></div>'
  objects = new Batman.Set('foo', 'bar')

  helpers.render source, {objects}, (node, view) ->
    objects.add('foo', 'baz', 'qux')
    delay =>
      deepEqual getPs(view), ['foo', 'bar', 'baz', 'qux']

asyncTest 'it should remove items from the DOM as they are removed from the set', ->
  source = '<div><p data-foreach-object="objects" class="present" data-bind="object"></p></div>'
  objects = new Batman.Set('foo', 'bar')

  helpers.render source, {objects}, (node, view) ->
    objects.remove('foo')
    delay =>
      deepEqual getPs(view), ['bar']

asyncTest 'it should atomically reorder DOM nodes when the set is reordered', ->
  source = '<div><p data-foreach-object="objects.sortedBy[currentSort]" class="present" data-bind="object.name"></p></div>'
  objects = new Batman.Set({id: 1, name: 'foo'}, {id: 2, name: 'bar'})
  context = {objects, currentSort: 'id'}

  helpers.render source, context, (node, view) ->
    deepEqual getPs(view), ['foo', 'bar']
    # multiple reordering all at once should not end up with duplicate DOM nodes
    view.set('currentSort', 'name')
    delay =>
      view.set('currentSort', 'id')
      delay =>
        view.set('currentSort', 'name')
        delay =>
          deepEqual getPs(view), ['bar', 'foo']

asyncTest 'it should add items in order', ->
  source = '<p data-foreach-object="objects.sortedBy.id" class="present" data-bind="object.name"></p>'
  objects = new Batman.Set({id: 1, name: 'foo'}, {id: 2, name: 'bar'})
  helpers.render source, {objects}, (node, view) ->
    objects.add({id: 0, name: 'zero'})
    delay ->
      delay ->
        deepEqual getPs(view), ['zero', 'foo', 'bar']

asyncTest 'it should allow data-context definitions on inner nodes', ->
  source = '<p data-context-object="outer.foo.bar" data-foreach-outer="objects" data-bind="object.name"></p>'
  objects = new Batman.Set({id: 1, name: 'foo'}, {id: 2, name: 'bar'})
  objects = objects.map (object) -> Batman(foo: Batman(bar: object))

  helpers.render source, {objects}, (node, view) ->
    deepEqual getPs(view).sort(), ['foo', 'bar'].sort()
    QUnit.start()

asyncTest 'prevents superview ready until first batch of children are rendered', 3, ->
  source = '<p data-foreach-object="objects" class="present" data-bind="object"></p>'
  objects = new Batman.Set('foo', 'bar', 'baz')

  node = document.createElement 'div'
  node.innerHTML = source

  view = new Batman.View({objects, node})

  view.event('ready').oneShot = true
  ok !view.event('ready')._oneShotFired, 'make sure views render async'

  view.on 'ready', =>
    ok view.get('node').childNodes.length > 1
    ok view.event('ready')._oneShotFired
    QUnit.start()

  view.initializeBindings()

asyncTest 'it should continue to render nodes after the loop', 1, ->
  source = '<p data-foreach-object="bar" class="present" data-bind="object"></p><span data-bind="foo"/>'
  objects = new Batman.Set('foo', 'bar', 'baz')

  helpers.render source, false, {bar: objects, foo: "qux"}, (node) ->
    equal 'qux', $('span', node).html(), "Node after the loop is also rendered"
    QUnit.start()

asyncTest 'it should render consecutive loops', 1, ->
  source = '<p data-foreach-object="objects1" data-bind="object"></p><p data-foreach-object="objects2" data-bind="object"></p>'
  objects1 = new Batman.Set('foo', 'bar', 'baz')
  objects2 = new Batman.Set('a', 'b', 'c')

  helpers.render source, false, {objects1, objects2}, (node, view) ->
    deepEqual getPs(view), ['foo', 'bar', 'baz', 'a', 'b', 'c']
    QUnit.start()

asyncTest 'it should render consecutive loops bound to the same collection', 4, ->
  source = '<p data-foreach-object="objects" data-bind="object"></p><p data-foreach-object="objects" data-bind="object"></p>'
  objects = new Batman.Set('foo', 'bar', 'baz')

  helpers.render source, false, {objects}, (node, view) ->
    deepEqual getPs(view), ['foo', 'bar', 'baz', 'foo', 'bar', 'baz']
    objects.remove 'foo'
    delay ->
      deepEqual getPs(view), ['bar', 'baz', 'bar', 'baz']
      objects.remove 'bar'
      delay ->
        deepEqual getPs(view), ['baz', 'baz']
        objects.remove 'baz'
        delay ->
          equal $('p', node).length, 0

asyncTest 'it should render consecutive loops bound to the same collection when the collection starts empty', 3, ->
  source = '<p data-foreach-object="objects" data-bind="object"></p><p data-foreach-object="objects" data-bind="object"></p>'
  objects = new Batman.Set()

  helpers.render source, false, {objects}, (node, view) ->
    equal $('p', node).length, 0
    objects.add 'foo', 'bar', 'baz'
    setTimeout (->
      deepEqual getPs(view), ['foo', 'bar', 'baz', 'foo', 'bar', 'baz']
      objects.remove 'bar'
      delay ->
        deepEqual getPs(view), ['foo', 'baz', 'foo', 'baz']
    ), 50

asyncTest 'it should update the whole set of nodes if the collection changes', ->
  source = '<p data-foreach-object="objects" class="present" data-bind="object"></p>'
  context = {objects: new Batman.Set('foo', 'bar', 'baz')}

  Batman.developer.suppress()
  helpers.render source, false, context, (node, view) ->
    equal $('.present', node).length, 3
    view.set('objects', new Batman.Set('qux', 'corge'))
    delay =>
      equal $('.present', node).length, 2
      view.set('objects', null)
      delay =>
        equal $('.present', node).length, 0
        view.set('objects', new Batman.Set('mario'))
        delay 60, =>
          equal $('.present', node).length, 1
          Batman.developer.unsuppress()

asyncTest 'it should not fail if the collection is cleared', ->
  source = '<p data-foreach-object="objects" class="present" data-bind="object"></p>'
  context = {objects: new Batman.Set('foo', 'bar', 'baz')}

  helpers.render source, false, context, (node, view) ->
    equal $('.present', node).length, 3
    view.get('objects').clear()
    delay =>
      equal $('.present', node).length, 0

asyncTest 'it should not fail if the iterator is killed', 1, ->
  source = '<p data-foreach-object="objects" class="present" data-bind="object"></p>'
  context = {objects: new Batman.Set([0...100]...)}

  oldIterator = Batman.DOM.IteratorBinding
  instance = false
  class Batman.DOM.IteratorBinding extends oldIterator
    constructor: ->
      instance = @
      super

  # Render the source
  helpers.render source, false, context, (node, view) ->

  # Wait till the first stack pop which will happen after the iterator is instantiated, but its children haven't finished
  Batman.setImmediate ->
    ok instance
    instance.die()

  delay ->

asyncTest 'previously observed collections shouldn\'t have any effect if they are replaced', ->
  source = '<p data-foreach-object="objects" class="present" data-bind="object"></p>'
  oldObjects = new Batman.Set('foo', 'bar', 'baz')
  context = {objects: oldObjects}

  helpers.render source, false, context, (node, view) ->
    view.set('objects', new Batman.Set('qux', 'corge'))
    oldObjects.add('no effect')
    delay =>
      equal $('.present', node).length, 2

asyncTest 'it should order loops among their siblings properly', 5, ->
  source = '<div><span data-bind="baz"></span><p data-foreach-object="bar" class="present" data-bind="object"></p><span data-bind="foo"></span></div>'
  objects = new Batman.Set('foo', 'bar', 'baz')

  helpers.render source, false, {baz: "corn", bar: objects, foo: "qux"}, (node) ->
    div = node.childNodes[0]
    equal 'corn', $('span', div).get(0).innerHTML, "Node before the loop is rendered"
    equal 'qux', $('span', div).get(1).innerHTML, "Node before the loop is rendered"
    equal 'p', div.childNodes[2].tagName.toLowerCase(), "Order of nodes is preserved"
    equal 'span', $(':first', div).get(0).tagName.toLowerCase(), "Order of nodes is preserved"
    equal 'span', $(':last', div).get(0).tagName.toLowerCase(), "Order of nodes is preserved"
    QUnit.start()

asyncTest 'it should order consecutive loops among their siblings properly', 1, ->
  Batman.Filters.times = (multiplicand, multiplier) -> multiplicand * multiplier
  source = '''
    <div>
      <p data-foreach-object="objects" data-bind="object"></p>
      <p data-foreach-object="objects" data-bind="object | times 2"></p>
      <p data-foreach-object="objects" data-bind="object | times 3"></p>
      <p data-foreach-object="objects" data-bind="object | times 4"></p>
    </div>
  '''
  objects = new Batman.Set(1,2,3)

  helpers.render source, false, {objects}, (node) ->
    div = node.childNodes[0]
    deepEqual getVals(div), [1,2,3,2,4,6,3,6,9,4,8,12]
    delete Batman.Filters.times
    QUnit.start()

asyncTest 'it should loop over hashes', 6, ->
  source = '<p data-foreach-player="playerScores" class="present" data-bind-id="player" data-bind="playerScores[player]"></p>'
  playerScores = new Batman.Hash(
    mario: 5
    link: 5
    crono: 10
  )

  helpers.render source, false, {playerScores}, (node, view) ->
    $('p', node).each (i, childNode) ->
      equal childNode.className,  'present'
      equal parseInt(childNode.innerHTML, 10), playerScores.get(childNode.id)
    QUnit.start()

asyncTest 'it should update as a hash has items added and removed', 8, ->
  source = '<div><p data-foreach-player="playerScores" data-bind-id="player" data-bind="playerScores[player]"></p></div>'
  context =
    playerScores: new Batman.Hash
      mario: 5

  helpers.render source, context, (node, view) ->
    equal $(':first', node).attr('id'), 'mario'
    equal $(':first', node).html(), '5'
    view.playerScores.set 'link', 10
    delay =>
      equal $(':first', node).attr('id'), 'mario'
      equal $(':first', node).html(), '5'
      equal $(':nth-child(2)', node).attr('id'), 'link'
      equal $(':nth-child(2)', node).html(), '10'
      view.playerScores.unset 'mario'
      delay =>
        equal $(':first', node).attr('id'), 'link'
        equal $(':first', node).html(), '10'

asyncTest 'it should loop over js objects', 6, ->
  source = '<p data-foreach-player="playerScores" class="present" data-bind-id="player" data-bind="playerScores[player]"></p>'
  playerScores =
    mario: 5
    link: 5
    crono: 10

  helpers.render source, false, {playerScores}, (node, view) ->
    $('p', node).each (i, childNode) ->
      equal childNode.className,  'present'
      equal parseInt(childNode.innerHTML, 10), playerScores[childNode.id]
    QUnit.start()

asyncTest 'it should loop over silly objects which return undefined for toArray', 3, ->
  source = '<p data-foreach-item="items" data-bind="item"></p>'
  items = Batman(toArray: [1, 2, 3])
  helpers.render source, Batman({items}), (node, view) ->
    equal getPs(view).length, 3
    items.set 'toArray', undefined
    equal getPs(view).length, 0
    items.set 'toArray', [1, 2]
    equal getPs(view).length, 2
    QUnit.start()

asyncTest 'it should prevent parent renders even if it has to defer (note: this test can take a while)', ->
  oldDeferEvery = Batman.DOM.IteratorBinding::deferEvery
  Batman.DOM.IteratorBinding::deferEvery = 0.5
  x = new Batman.Set([0...500]...)
  context = {x}
  source = '''<div data-foreach-obj="x">
    <p data-bind="obj"></p>
  </div>'''
  helpers.render source, context, (node, view) ->
    deepEqual getPs(view), [0...500].map((x) -> (x).toString())
    Batman.DOM.IteratorBinding::deferEvery = oldDeferEvery
    QUnit.start()

asyncTest 'it shouldn\'t become desynchronized if the foreach collection observer fires with the same collection', ->
  x = new Batman.Set("a", "b", "c", "d", "e")
  context = {x}
  source = '<p data-foreach-obj="x" data-bind="obj"></p>'
  helpers.render source, context, (node, view) ->
    deepEqual getPs(view), ['a', 'b', 'c', 'd', 'e']
    view.observe 'x', spy = createSpy()
    view.property('x').fire(x,x,'x')
    delay ->
      ok spy.called
      deepEqual getPs(view), ['a', 'b', 'c', 'd', 'e']

asyncTest 'it shouldn\'t become desynchronized if the collection removes successively', ->
  x =  new Batman.Set("a", "b", "c", "d", "e")
  source = '<p data-foreach-obj="x" data-bind="obj"></p>'
  helpers.render source, {x}, (node, view) ->
    deepEqual getPs(view), ['a', 'b', 'c', 'd', 'e']
    for y in ['b', 'c', 'd', 'e']
      x.remove y
    delay ->
      deepEqual getPs(view), ['a']

asyncTest 'it shouldn\'t become desynchronized if the collection adds successively', ->
  x =  new Batman.Set("a")
  source = '<p data-foreach-obj="x" data-bind="obj"></p>'
  helpers.render source, {x}, (node, view) ->
    deepEqual getPs(view), ['a']
    for y in ['b', 'c']
      x.add y
    delay ->
      deepEqual getPs(view), ['a', 'b', 'c']

asyncTest 'it shouldn\'t become desynchronized if the collection adds and removes successively', ->
  x =  new Batman.Set("a", "b", "c", "d", "e")
  source = '<p data-foreach-obj="x" data-bind="obj"></p>'
  helpers.render source, {x}, (node, view) ->
    deepEqual getPs(view), ['a', 'b', 'c', 'd', 'e']
    x.add 'f'
    x.remove 'c'
    x.remove 'f'
    x.add 'c'
    setTimeout (->
      deepEqual getPs(view).sort(), ['a', 'b', 'c', 'd', 'e']
      deepEqual getPs(view), x.get('toArray')
      QUnit.start()
    ), 80

asyncTest 'it shouldn\'t become desynchronized with a fancy filtered style set', ->
  x = Batman(all: new Batman.Set("a", "b", "c", "d", "e"))
  x.accessor 'filtered',
    get: ->
      unless @filtered?
        @filtered = new Batman.Set()
        @filtered.add @get('all').toArray()...
      @filtered.sortedBy('valueOf')
    set: (k,v) ->
      set = @get('filtered')
      @get('all').forEach (e) ->
        if v is '' or e == v then set.add(e) else set.remove(e)
      set

  source = '<p data-foreach-obj="x.filtered" data-bind="obj"></p>'
  helpers.render source, {x}, (node, view) ->
    deepEqual getPs(view), ['a', 'b', 'c', 'd', 'e']
    x.set 'filtered', 'a'
    delay ->
      deepEqual getPs(view), ['a']
      x.set 'filtered', ''
      delay ->
        deepEqual getPs(view), ['a', 'b', 'c', 'd', 'e']
        x.set 'filtered', 'a'
        x.set 'filtered', ''
        delay ->
          deepEqual getPs(view), ['a', 'b', 'c', 'd', 'e']

getVals = (node) ->
  parseInt(child.innerHTML, 10) for child in $(node).children()

asyncTest 'it should stop previous ongoing renders if items are removed', ->
  getSet = (seed) -> new Batman.Set(seed, seed+1, seed+2)
  context = {all: getSet(1)}

  source = '<p data-foreach-obj="all" data-bind="obj"></p>'
  helpers.render source, false, context, (node, view) ->
    deepEqual getVals(node), [1,2,3]
    view.get('all').add(4)
    view.get('all').remove(4)
    delay ->
      deepEqual getVals(node), [1,2,3]

asyncTest 'it should stop previous ongoing renders if the collection is changed', ->
  getSet = (seed) -> new Batman.Set(seed, seed+1, seed+2)
  context = {all: getSet(1)}

  source = '<p data-foreach-obj="all" data-bind="obj"></p>'
  helpers.render source, false, context, (node, view) ->
    deepEqual getVals(node), [1,2,3]
    view.set('all', getSet(5))
    view.set('all', getSet(10))
    delay ->
      deepEqual getVals(node), [10,11,12]

asyncTest 'it should stop previous ongoing renders if collection changes, but intersects', ->
  getSet = (seed) -> new Batman.Set(seed, seed+1, seed+2)
  context = {all: getSet(1)}

  source = '<p data-foreach-obj="all" data-bind="obj"></p>'
  helpers.render source, false, context, (node, view) ->
    deepEqual getVals(node), [1,2,3]
    view.set('all', getSet(2))
    delay ->
      deepEqual getVals(node), [2,3,4]
      view.set('all', getSet(3))
      view.set('all', getSet(4))
      delay ->
        deepEqual getVals(node), [4,5,6]

asyncTest 'it shouldn\'t become desynchronized if the collection originates from a partial', ->
  context =
    parent: Batman
      children: new Batman.Set("a", "b", "c", "d", "e")

  source = '''
    <div data-defineview="objview">
      <div data-foreach-object="parent.children">
        <p data-bind="object"></p>
      </div>
    </div>
    <div data-partial="objview"></div>
  '''

  helpers.render source, context, (node, view) ->
    deepEqual getPs(view), ['a', 'b', 'c', 'd', 'e']
    delay ->
      deepEqual getPs(view), ['a', 'b', 'c', 'd', 'e']
      view.get('parent.children').remove('b')
      delay ->
        deepEqual getPs(view), ['a', 'c', 'd', 'e']
        for k in ['c', 'e']
          view.get('parent.children').remove(k)
        delay ->
          deepEqual getPs(view), ['a','d']

asyncTest 'it should propagate notifications of inner binding creation to bindings outside the loop', ->
  context =
    children: new Batman.Set("a", "b", "c", "d", "e")

  spy = createSpy()
  class TestBinding extends Batman.DOM.AbstractBinding
    childBindingAdded: spy

  Batman.DOM.readers.test = -> new TestBinding(arguments...)

  source = '''
    <div data-test="true">
      <div data-foreach-object="children">
        <p data-bind="object"></p>
      </div>
    </div>
  '''

  helpers.render source, context, (node, view) ->
    delay ->
      ok spy.callCount, 5
      view.children.add 'f'
      delay ->
        ok spy.callCount, 6

asyncTest 'it should destroy nodes and their bindings if items have been removed before render is complete', 1, ->
  source = '<div data-foreach-item="items"><span data-bind="item.id"></span></div>'

  dieVals = []
  Batman.DOM.AbstractBinding::die = ->
    dieVals.push [@key, @node.innerHTML] if @key is 'item.id'

  helpers.render source, {}, (node, view) ->
    view.set 'items', new Batman.Set({id: 4}, {id: 5}, {id: 6})
    view.set 'items', new Batman.Set({id: 7}, {id: 8}, {id: 9})
    delay ->
      deepEqual dieVals, [['item.id', '4'], ['item.id', '5'], ['item.id', '6']]
