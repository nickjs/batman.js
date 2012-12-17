helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.View iterator bindings'

asyncTest 'it should destroy nodes and their bindings if items have been removed before render is complete', 1, ->
  source = '<div data-foreach-item="items"><span data-bind="item.id"></span></div>'

  dieVals = []
  Batman.DOM.AbstractBinding::die = ->
    dieVals.push [@key, @node.innerHTML] if @key is 'item.id'

  context = new Batman
  helpers.render source, context
  , (node) ->
    context.set 'items', new Batman.Set({id: 4}, {id: 5}, {id: 6})
    context.set 'items', new Batman.Set({id: 7}, {id: 8}, {id: 9})
    delay ->
      deepEqual dieVals, [['item.id', '4'], ['item.id', '5'], ['item.id', '6']]
      QUnit.start()
