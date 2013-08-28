helpers = window.viewHelpers

preventDefault = Batman.DOM.preventDefault

QUnit.module "Batman.DOM events",
  teardown: ->
    Batman.DOM.preventDefault = preventDefault

asyncTest "the click handler calls preventDefault", ->
  Batman.DOM.preventDefault = createSpy()

  node = document.createElement('div')
  Batman.DOM.events.click node, ->
    equal Batman.DOM.preventDefault.callCount, 1
    QUnit.start()

  helpers.triggerClick(node)

asyncTest "the click handler does not preventDefault if told not to", ->
  Batman.DOM.preventDefault = createSpy()

  node = document.createElement('div')
  callback = ->
    equal Batman.DOM.preventDefault.callCount, 0
    QUnit.start()
  Batman.DOM.events.click(node, callback, null, 'click', false)

  helpers.triggerClick(node)
