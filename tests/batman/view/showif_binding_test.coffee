helpers = window.viewHelpers

QUnit.module 'Batman.View visibility bindings',
asyncTest 'it should allow visibility to be bound on block elements', 2, ->
  testDiv = $('<div/>')
  testDiv.appendTo($('body'))
  blockDefaultDisplay = testDiv.css('display')
  testDiv.remove()
  source = '<div data-showif="foo"></div>'
  helpers.render source,
    foo: true
  , (node) ->
    # Must put the node in the DOM for the style to be calculated properly.
    helpers.withNodeInDom node, ->
      equal node.css('display'), blockDefaultDisplay

    helpers.render source,
      foo: false
    , (node) ->
        helpers.withNodeInDom node, ->
          equal node.css('display'), 'none'
        QUnit.start()

asyncTest 'it should allow visibility to be bound on inline elements', 2, ->
  testSpan = $('<span/>')
  testSpan.appendTo($('body'))
  inlineDefaultDisplay = testSpan.css('display')
  testSpan.remove()
  source = '<span data-showif="foo"></span>'
  helpers.render source,
    foo: true
  , (node) ->
    # Must put the node in the DOM for the style to be calculated properly.
    helpers.withNodeInDom node, ->
      equal node.css('display'), inlineDefaultDisplay

    helpers.render source,
      foo: false
    , (node) ->
        helpers.withNodeInDom node, ->
          equal node.css('display'), 'none'
        QUnit.start()

asyncTest "it should ignore an inline style of 'display:none' on block elements when determining an element's original display setting", 2, ->
  testDiv = $('<div/>')
  testDiv.appendTo($('body'))
  blockDefaultDisplay = testDiv.css('display')
  testDiv.remove()
  source = '<div data-showif="foo" style="display:none"></div>'
  helpers.render source,
    foo: true
  , (node) ->
    # Must put the node in the DOM for the style to be calculated properly.
    helpers.withNodeInDom node, ->
      equal node.css('display'), blockDefaultDisplay

    helpers.render source,
      foo: false
    , (node) ->
        helpers.withNodeInDom node, ->
          equal node.css('display'), 'none'
        QUnit.start()

asyncTest "it should ignore an inline style of 'display:none' on inline elements when determining an element's original display setting", 2, ->
  testSpan = $('<span/>')
  testSpan.appendTo($('body'))
  inlineDefaultDisplay = testSpan.css('display')
  testSpan.remove()
  source = '<span data-showif="foo" style="display:none"></span>'
  helpers.render source,
    foo: true
  , (node) ->
    # Must put the node in the DOM for the style to be calculated properly.
    helpers.withNodeInDom node, ->
      equal node.css('display'), inlineDefaultDisplay

    helpers.render source,
      foo: false
    , (node) ->
        helpers.withNodeInDom node, ->
          equal node.css('display'), 'none'
        QUnit.start()

asyncTest 'it should show for a proxy with a target and hide if the value is a proxy with no target', 2, ->
  testSpan = $('<span/>')
  testSpan.appendTo($('body'))
  inlineDefaultDisplay = testSpan.css('display')
  testSpan.remove()
  source = '<span data-showif="foo"></span>'
  helpers.render source,
    foo: new Batman.Proxy(new Batman.Object)
  , (node) ->
    # Must put the node in the DOM for the style to be calculated properly.
    helpers.withNodeInDom node, ->
      equal node.css('display'), inlineDefaultDisplay

    helpers.render source,
      foo: new Batman.Proxy
    , (node) ->
        helpers.withNodeInDom node, ->
          equal node.css('display'), 'none'
        QUnit.start()