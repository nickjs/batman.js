helpers = window.viewHelpers

QUnit.module 'Batman.DOM.Yield',
  setup: ->
    @containerNode = document.createElement('div')
    @superview = new Batman.View(node: @containerNode)
    @view = new Batman.View(html: 'Inner view')

    @yield = Batman.DOM.Yield.withName('test')
    @yield.set('containerNode', @containerNode)

  teardown: ->
    Batman.DOM.Yield.reset()

test "setting the contentView should add the node to the container node", ->
  @superview.subviews.add(@view)
  @yield.set('contentView', @view)
  equal @containerNode.childNodes.length, 1

QUnit.module 'Batman.View yield, contentFor, and replace rendering',
  teardown: ->
    Batman.DOM.Yield.reset()

asyncTest 'it should insert content into yields when the content comes before the yield', 1, ->
  source = '''
  <div data-contentfor="baz">chunky bacon</div>
  <div data-yield="baz" id="test">erased</div>
  '''
  helpers.render source, {}, (node) ->
    equal node.html(), "chunky bacon"
    QUnit.start()

asyncTest 'it should insert content into yields when the content comes after the yield', 1, ->
  source = '''
  <div data-yield="baz" class="test">erased</div>
  <span data-contentfor="baz">chunky bacon</span>
  '''
  helpers.render source, {}, (node, view) ->
    equal node.children(0).html(), "chunky bacon"
    QUnit.start()

asyncTest 'bindings within yielded content should continue to update when the content comes before the yield', 2, ->
  source = '''
  <div data-contentfor="baz"><p data-bind="string"></p></div>
  <div data-yield="baz"></div>
  '''
  helpers.render source, {string: "chunky bacon"}, (node, view) ->
    equal node.find('p').html(), "chunky bacon"
    view.set('string', 'why so serious')
    equal node.find('p').html(), "why so serious"
    QUnit.start()

asyncTest 'bindings within yielded content should continue to update when the content comes after the yield', 2, ->
  source = '''
  <div data-yield="baz"></div>
  <div data-contentfor="baz"><p data-bind="string"></p></div>
  '''
  helpers.render source, {string: "chunky bacon"}, (node, view) ->
    equal node.find('p').html(), "chunky bacon"
    view.set('string', 'why so serious')
    equal node.find('p').html(), "why so serious"
    QUnit.start()

asyncTest 'event handlers within yielded content should continue to fire when the content comes before the yield', 1, ->
  source = '''
  <div data-yield="baz"></div>
  <div data-contentfor="baz"><button data-event-click="handleClick"></p></div>
  '''
  context = handleClick: spy = createSpy()
  helpers.render source, context, (node) ->
    helpers.triggerClick node.find('button')[0]
    ok spy.called
    QUnit.start()

asyncTest 'event handlers within yielded content should continue to fire when the content comes before the yield', 1, ->
  source = '''
  <div data-contentfor="baz"><button data-event-click="handleClick"></p></div>
  <div data-yield="baz"></div>
  '''
  context = handleClick: spy = createSpy()
  helpers.render source, context, (node) ->
    helpers.triggerClick node.find('button')[0]
    ok spy.called
    QUnit.start()

asyncTest 'it shouldn\'t go nuts if the content is already inside the yield', 1, ->
  source = '''
    <div data-yield="baz" class="test">
      <span data-contentfor="baz">chunky bacon</span>
    </div>
  '''
  node = helpers.render source, {}, (node) ->
    equal node.children(0).html(), "chunky bacon"
    QUnit.start()

asyncTest 'it should render content even if the yield doesn\'t exist yet', 1, ->
  helpers.render '<div data-contentfor="foo">immediate</div>', {}, (content) ->
    helpers.render '<div data-yield="foo"></div>', {}, (node) ->
      equal node.children(0).html(), 'immediate'
      QUnit.start()
