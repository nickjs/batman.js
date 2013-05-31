helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.DOM.Yield',
  setup: ->
    @yield = Batman.DOM.Yield.withName('test')
    @containerNode = document.createElement('div')
    @yield.set('containerNode', @containerNode)
    @nodeA = document.createElement('div')
    @nodeB = document.createElement('div')

  teardown: ->
    Batman.DOM.Yield.reset()

test "append(node) should add the node to the container node", ->
  @yield.append(@nodeA)
  equal @containerNode.childNodes.length, 1

test "replace(node) should leave only that node to the container node", ->
  @yield.append(@nodeA)
  @yield.replace(@nodeB)
  equal @containerNode.childNodes.length, 1
  equal @containerNode.childNodes[0], @nodeB

test "clear() should remove all nodes", ->
  @yield.append(@nodeA)
  @yield.append(@nodeB)
  @yield.clear()
  equal @containerNode.childNodes.length, 0

test "cycle() and then clearStale() should remove nodes added before cycle()", ->
  @yield.append(@nodeA)
  @yield.cycle()
  @yield.clearStale()
  equal @containerNode.childNodes.length, 0

test "cycle() and then clearStale() should keep nodes added after cycle()", ->
  @yield.cycle()
  @yield.append(@nodeB)
  @yield.clearStale()
  equal @containerNode.childNodes.length, 1
  equal @containerNode.childNodes[0], @nodeB

test "clear() after append() should remove references to old nodes", ->
  @yield.append(@nodeA)
  @yield.append(@nodeB)
  @yield.clear()
  deepEqual @yield.currentVersionNodes, []

QUnit.module 'Batman.View yield, contentFor, and replace rendering',
  teardown: ->
    Batman.DOM.Yield.reset()

asyncTest 'it should insert content into yields when the content comes before the yield', 1, ->
  source = '''
  <div data-contentfor="baz">chunky bacon</div>
  <div data-yield="baz" id="test">erased</div>
  '''
  node = helpers.render source, {}, (node) ->
    equal node.children(0).html(), "chunky bacon"
    QUnit.start()

asyncTest 'it should insert content into yields when the content comes after the yield', 1, ->
  source = '''
  <div data-yield="baz" class="test">erased</div>
  <span data-contentfor="baz">chunky bacon</span>
  '''
  node = helpers.render source, {}, (node) ->
    equal node.children(0).html(), "chunky bacon"
    QUnit.start()

asyncTest 'bindings within yielded content should continue to update when the content comes before the yield', 2, ->
  source = '''
  <div data-contentfor="baz"><p data-bind="string"></p></div>
  <div data-yield="baz"></div>
  '''
  context = Batman string: "chunky bacon"
  helpers.render source, context, (node) ->
    equal node.find('p').html(), "chunky bacon"
    context.set 'string', 'why so serious'
    equal node.find('p').html(), "why so serious"
    QUnit.start()

asyncTest 'bindings within yielded content should continue to update when the content comes after the yield', 2, ->
  source = '''
  <div data-yield="baz"></div>
  <div data-contentfor="baz"><p data-bind="string"></p></div>
  '''
  context = Batman string: "chunky bacon"
  helpers.render source, context, (node) ->
    equal node.find('p').html(), "chunky bacon"
    context.set 'string', 'why so serious'
    equal node.find('p').html(), "why so serious"
    QUnit.start()

asyncTest 'bindings within nested yielded content should continue to update', 2, ->
  source = '''
  <div data-yield="baz">
    <div data-replace="baz">
      <p data-bind="string"></p>
    </div>
  </div>
  '''
  context = Batman string: "chunky bacon"
  helpers.render source, context, (node) ->
    equal node.find('p').html(), "chunky bacon"
    context.set 'string', 'why so serious'
    equal node.find('p').html(), "why so serious"
    QUnit.start()

asyncTest 'event handlers within yielded content should continue to fire when the content comes before the yield', 1, ->
  source = '''
  <div data-yield="baz"></div>
  <div data-contentfor="baz"><button data-event-click="handleClick"></p></div>
  '''
  context = Batman handleClick: spy = createSpy()
  helpers.render source, context, (node) ->
    helpers.triggerClick node.find('button')[0]
    ok spy.called
    QUnit.start()

asyncTest 'event handlers within yielded content should continue to fire when the content comes before the yield', 1, ->
  source = '''
  <div data-contentfor="baz"><button data-event-click="handleClick"></p></div>
  <div data-yield="baz"></div>
  '''
  context = Batman handleClick: spy = createSpy()
  helpers.render source, context, (node) ->
    helpers.triggerClick node.find('button')[0]
    ok spy.called
    QUnit.start()

asyncTest 'event handlers in nested yielded content should continue to fire', ->
  source = '''
    <div data-yield="foo">
      <div data-replace="foo">
        <button data-event-click="hmm"></button>
      </div>
    </div>
  '''

  context =
    hmm: spy = createSpy()

  helpers.render source, context, (node) ->
    helpers.triggerClick(node.find('button')[0])
    ok spy.called
    QUnit.start()

asyncTest 'it should yield multiple contentfors that render into the same yield', ->
  source = '''
  <div data-yield="mult" class="test"></div>
  <span data-contentfor="mult">chunky bacon</span>
  <span data-contentfor="mult">spicy sausage</span>
  '''
  node = helpers.render source, {}, (node) ->
    equal node.children(0).first().html(), "chunky bacon"
    equal node.children(0).first().next().html(), "spicy sausage"
    QUnit.start()

asyncTest 'it shouldn\'t go nuts if the content is already inside the yield', 1, ->
  source = '<div data-yield="baz" class="test">
              <span data-contentfor="baz">chunky bacon</span>
            </div>'
  node = helpers.render source, {}, (node) ->
    equal node.children(0).html(), "chunky bacon"
    QUnit.start()

asyncTest 'it should render content even if the yield doesn\'t exist yet', 1, ->
  helpers.render '<div data-contentfor="foo">immediate</div>', {}, (content) ->
    helpers.render '<div data-yield="foo"></div>', {}, (node) ->
      equal node.children(0).html(), 'immediate'
      QUnit.start()

asyncTest 'data-replace should replace content without breaking contentfors', 2, ->
  source = '''
    <div data-yield="foo">start</div>
    <div data-replace="foo">replaces</div>
    <div data-contentfor="foo">appends</div>
  '''
  helpers.render source, {}, (node) ->
    equal node.children(0).first().html(), 'replaces'
    equal node.children(0).first().next().html(), 'appends'
    QUnit.start()

asyncTest "views should be able to yield more than once", ->
  viewInstance = false
  class TestView extends Batman.View
    cached: true
    constructor: ->
      viewInstance = @
      super

  source = '''
    <div class="yield" data-yield="foo"></div>
    <span class="view" data-view="TestView"><div data-contentfor="foo">testing</div></span>
  '''

  context = Batman {TestView}
  helpers.render source, false, context, (node) ->
    destination = node.childNodes[0]
    source = node.childNodes[2]
    equal destination.innerHTML, '<div data-contentfor="foo">testing</div>'
    Batman.DOM.destroyNode(source)
    equal destination.innerHTML, ""

    Batman.DOM.appendChild(node, viewInstance.get('node'))
    equal destination.innerHTML, '<div data-contentfor="foo">testing</div>'
    QUnit.start()
