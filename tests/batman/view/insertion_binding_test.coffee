helpers = if typeof require is 'undefined' then window.viewHelpers else require './view_helper'

QUnit.module 'Batman.View insertion bindings'
  setup: ->
    class @TestView extends Batman.View
      constructor: ->
        @constructor.instance = @
        super

asyncTest 'it should allow elements to be removeed when the keypath evaluates to true', 3, ->
  source = '<div class="foo" data-removeif="foo"></div>'
  context = Batman foo: true
  helpers.render source, false, context, (node) ->
    equal $('.foo', node).length, 0
    context.set 'foo', false
    equal $('.foo', node).length, 1
    context.set 'foo', true
    equal $('.foo', node).length, 0
    QUnit.start()

asyncTest 'it should allow elements to be inserted when the keypath evaluates to true', 2, ->
  source = '<div class="foo" data-insertif="foo"></div>'
  context = Batman foo: true
  helpers.render source, false, context, (node) ->
    equal $('.foo', node).length, 1
    context.set 'foo', false
    equal $('.foo', node).length, 0
    QUnit.start()

asyncTest 'it should leave a comment node so bindings are properly destroyed', 1, ->
  source = '<div data-removeif="foo"><div data-view="OuterView"></div></div>'

  context = Batman
    foo: true
    OuterView: class OuterView extends @TestView

  helpers.render source, false, context, (node) ->
    context.OuterView.instance.on 'destroy', spy = createSpy()
    Batman.DOM.destroyNode(node)
    ok spy.called
    QUnit.start()
